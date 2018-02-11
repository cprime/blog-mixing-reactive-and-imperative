# Mixing Imperative and Reactive Components in Swift

When working on projects that contain both reactive and imperative code, I run into a common challenge:

_How do I write asynchronous reactive code that calls out to components which rely on completion-blocks?_

This arises most frequently when I am integrating completion-block-based networking components with reactive ViewModels. For example, suppose I have a UserManager object that makes API calls and passes the result of those calls back to the caller using completion-blocks:

```
// UserManager

func getUser(withUserID userID: String, completion: @escaping (Result<User>) -> Void) {
    let request = Request(...)
    networkingLayer.sendRequest(request) { result in
        // Process result and call completion
    }
}

func getUsers(withGroupID groupID: String, completion: @escaping (Result<[User]>) -> Void) {
    let request = Request(...)
    networkingLayer.sendRequest(request) { result in
        // Process result and call completion
    }
}
```

Unfortunately, these functions alone do not enable me to write "good" reactive code in my ViewModel. At first, I thought the best I could do was to rely on BehaviorSubjects, and to mix imperative and reactive code as follows:

```
// ViewModel

private let user: BehaviorSubject<User?> = BehaviorSubject(value: nil)
private let group: BehaviorSubject<[User]> = BehaviorSubject(value: [])

UserManager.shared.getUser(withUserID: userID) { [weak self] result in
    if case .success(let user) = result {
        self?.user.onNext(user)
        UserManager.shared.getUsers(withGroupID: user.groupID) { [weak self] result in
            if case .success(let users) = result {
                self?.group.onNext(users)
            }
        }
    }
}
```

Thinking about it a bit more, a better approach would be to wrap the existing completion-block-based UserManager functions, returning Observables. This approach is better because it exposes a reactive interface to the ViewModel. In this case, this reactive interface is:

```
// UserManager

func getUser(withUserID userID: String) -> Observable<User> {
    return Observable.create({ [weak self] observer in
        self?.getUser(withUserID: userID, completion: { result in
            switch result {
            case .success(let element):
                observer.on(.next(element))
                observer.on(.completed)
            case .failure(let error):
                observer.on(.error(error))
            }
        })
        return Disposables.create()
    })
}

func getUsers(withGroupID groupID: String) -> Observable<[User]> {
    return Observable.create({ [weak self] observer in
        self?.getUsers(withGroupID: groupID, completion: { result in
            switch result {
            case .success(let element):
                observer.on(.next(element))
                observer.on(.completed)
            case .failure(let error):
                observer.on(.error(error))
            }
        })
        return Disposables.create()
    })
}
```

However, this unfortunately requires me to generate a lot of boilerplate code. As you can imagine, this pattern will need to be repeated for all networking code across the entire app. When I was confronted with this scenario as an RxSwift newbie, I quickly gave up on trying to introduce Rx to my networking layer.

Fortunately, I then realized I could define a single Observable extension to eliminate the boilerplate code. In this extension, an Observable is created by passing in a closure that takes in the completion-block as an argument:

```
extension Observable {
    static func create(from block: @escaping (@escaping (Result<Element>) -> Void) -> ()) -> Observable<Element> {
        return Observable.create({ observer in
            block({ result in
                switch result {
                case .success(let element):
                    observer.on(.next(element))
                    observer.on(.completed)
                case .failure(let error):
                    observer.on(.error(error))
                }
            })
            return Disposables.create()
        })
    }
}
```

After creating this extension, I can simplify my UserManager functions to:

```
// UserManager

func getUser(withUserID userID: String) -> Observable<User> {
    return Observable.create(from: { [weak self] completion in
        self?.getUser(withUserID: userID, completion: completion)
    })
}

func getUsers(withGroupID groupID: String) -> Observable<[User]> {
    return Observable.create(from: { [weak self] completion in
        self?.getUsers(withGroupID: groupID, completion: completion)
    })
}
```

And rewrite my ViewModel code as:

```
// ViewModel

private let user: Observable<User>
private let group: Observable<[User]>

user = UserManager.shared
    .getUser(withUserID: userID)
    .share(replay: 1)
group = user
    .map({ $0.groupID })
    .flatMapLatest({ UserManager.shared.getUsers(withGroupID: $0) })
    .share(replay: 1)
```

As you can see, after employing this Observable extension, I was able to write the ViewModel code in a declarative and reactive way _and_  introduce a reactive interface into the networking layer without introducing a lot of boilerplate code.

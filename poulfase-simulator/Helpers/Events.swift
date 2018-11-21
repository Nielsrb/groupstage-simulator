/**
 *  Created by Freek Zijlmans, 2017-2018
 */

import Foundation

// MARK: - EventListener.
// Wrapper around listeners (targets) and functions.
fileprivate final class EventListener<T> {
    
    weak var target: AnyObject?
    private var closure: (T) -> Void
    fileprivate let once: Bool
    
    init(target: AnyObject, closure: @escaping (T) -> Void, once: Bool = false) {
        self.target = target
        self.closure = closure
        self.once = once
    }
    
    func invoke(arguments: T) -> Bool {
        guard target != nil else {
            return false
        }
        closure(arguments)
        return true
    }
    
}

//
// MARK: - Event class.
public class Event<T> {
    
    private var listeners: [EventListener<T>] = []
    
    public init() {}
    
    @discardableResult
    public func bind(_ target: AnyObject, _ closure: @escaping (T) -> Void) -> Self {
        listeners.append(EventListener<T>(target: target, closure: closure))
        return self
    }
    
    @discardableResult
    public func bindOnce(_ target: AnyObject, _ closure: @escaping (T) -> Void) -> Self {
        listeners.append(EventListener<T>(target: target, closure: closure, once: true))
        return self
    }
    
    @discardableResult
    public func unbind(_ target: AnyObject) -> Self {
        listeners = listeners.filter { listener in
            return listener.target !== target
        }
        return self
    }
    
    @discardableResult
    public func unbindAll() -> Self {
        listeners.removeAll()
        return self
    }
    
    @discardableResult
    public func emit(_ data: T) -> Self {
        listeners = listeners.filter { listener in
            return listener.invoke(arguments: data) && !listener.once
        }
        return self
    }
    
    public func numberOfBinds() -> Int {
        return listeners.count
    }
}

public extension Event where T == Void {
    @discardableResult
    public func emit() -> Self {
        return emit(())
    }
}

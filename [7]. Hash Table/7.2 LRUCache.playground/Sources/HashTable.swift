import Foundation

public struct HashTable<Key: Hashable, Value> {
    private typealias Element = (key: Key, value: Value)
    private typealias Bucket = [Element]
    private var buckets: [Bucket]

    /// 散列表中键值对的个数
    private(set) public var count = 0
    
    public var isEmpty: Bool { return count == 0 }
    
    /// 创建一个默认能容纳capacity个键值对的散列表
    public init(capacity: Int) {
        precondition(capacity > 0)
        buckets = Array<Bucket>(repeating: [], count: capacity)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            if let value = newValue {
                updateValue(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    /// 返回给定key对应的value
    public func value(forKey key: Key) -> Value? {
        let index = self.index(forKey: key)
        for element in buckets[index] {
            if element.key == key {
                return element.value
            }
        }
        return nil
    }
    
    /// 如果给定key已经存在则更新对应的值
    /// 如果不存在，则新插入一个键值对
    @discardableResult public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        let index = self.index(forKey: key)
        
        for (i, element) in buckets[index].enumerated() {
            if element.key == key {
                let oldValue = element.value
                buckets[index][i].value = value
                return oldValue
            }
        }
        
        // 该key还不存在，则新添加一个元素
        buckets[index].append((key: key, value: value))
        count += 1
        return nil
    }
    
    /// 移除指定的键值对
    @discardableResult public mutating func removeValue(forKey key: Key) -> Value? {
        let index = self.index(forKey: key)
        
        for (i, element) in buckets[index].enumerated() {
            if element.key == key {
                buckets[index].remove(at: i)
                count -= 1
                return element.value
            }
        }
        // 该key不存在
        return nil
    }
    
    public mutating func removeAll() {
        /// 重新初始化“桶”
        buckets = Array<Bucket>(repeating: [], count: buckets.count)
        count = 0
    }
    
    /// 计算给定key对应的index
    private func index(forKey key: Key) -> Int {
        return abs(key.hashValue % buckets.count)
    }
}

extension HashTable: CustomStringConvertible {
    public var description: String {
        let pairs = buckets.flatMap { b in b.map { e in "\(e.key) = \(e.value)" } }
        return pairs.joined(separator: ", ")
    }
    
    public var debugDescription: String {
        var str = ""
        for (i, bucket) in buckets.enumerated() {
            let pairs = bucket.map { e in "\(e.key) = \(e.value)" }
            str += "bucket \(i): " + pairs.joined(separator: ", ") + "\n"
        }
        return str
    }
}

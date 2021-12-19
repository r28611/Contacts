import Foundation
protocol MessageProtocol {
    var text: String? { get set }
    var image: Data? { get set }
    var audio: Data? { get set }
    var video: Data? { get set }
    var sendDate: Date { get set }
    var senderID: UInt { get set }
}
struct Message: MessageProtocol {
    var text: String?
    var image: Data?
    var audio: Data?
    var video: Data?
    var sendDate: Date
    var senderID: UInt
}

protocol StatisticDelegate: AnyObject {
    
    func handle(message: MessageProtocol)
}
protocol MessengerProtocol {
    
    var messages: [MessageProtocol] { get set }
    
    var statisticDelegate: StatisticDelegate? { get set }
    var dataSource: MessengerDataSourceProtocol? { get set }
    init()
    
    mutating func receive(message: MessageProtocol)
    
    mutating func send(message: MessageProtocol)
}

class Messenger: MessengerProtocol {
    var messages: [MessageProtocol]
    weak var statisticDelegate: StatisticDelegate?
    weak var dataSource: MessengerDataSourceProtocol? { didSet {
        if let source = dataSource { messages = source.getMessages()}}}
    required init() {
        messages = []
    }
    func receive(message: MessageProtocol) {
        statisticDelegate?.handle(message: message)
        messages.append(message) // ...
        // прием сообщения
        // ...
    }
    func send(message: MessageProtocol) {
        statisticDelegate?.handle(message: message)
        messages.append(message) // ...
        // отправка сообщения
        // ...
    }
}
protocol MessengerDataSourceProtocol: AnyObject {
    func getMessages() -> [MessageProtocol]
}

extension Messenger: StatisticDelegate {
    func handle(message: MessageProtocol) {
        print("обработка сообщения от User # \(message.senderID) завершена")
    }
}

extension Messenger: MessengerDataSourceProtocol {
    func getMessages() -> [MessageProtocol] {
        return [Message(text: "Как дела?", sendDate: Date(), senderID: 2)] }
}
var messenger = Messenger()
messenger.dataSource = messenger.self
messenger.messages.count // 1

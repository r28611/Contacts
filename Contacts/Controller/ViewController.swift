//
//  ViewController.swift
//  Contacts
//
//  Created by Margarita Novokhatskaia on 19/12/2021.
//

import UIKit

class ViewController: UIViewController {
    var userDefaults = UserDefaults.standard
    var storage: ContactStorageProtocol!
    private var contacts: [ContactProtocol] = [] {
        didSet {
            contacts.sort{ $0.title < $1.title }
            storage.save(contacts: contacts)
        }
    }
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.setItems([UIBarButtonItem.flexibleSpace(),
                      .init(title: "Создать контакт", style: .plain, target: self, action: #selector(showNewContactAlert)),
                     ], animated: true)
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        setupTableView()
        storage = ContactStorage()
        loadContacts()
    }
    
    private func setupUi() {
        view.addSubview(tableView)
        view.addSubview(toolbar)
        let margins = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            toolbar.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            toolbar.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: margins.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    
    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
    }
    
    @objc private func showNewContactAlert() {
        
        let alertController = UIAlertController(title: "Создайте новый контакт",
                                                message: "Введите имя и телефон",
                                                preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Имя" }
        alertController.addTextField { textField in
            textField.placeholder = "Номер телефона" }
        
        let createButton = UIAlertAction(title: "Создать", style: .default) { _ in
            guard let contactName = alertController.textFields?[0].text,
                  let contactPhone = alertController.textFields?[1].text else { return }
            
            let contact = Contact(title: contactName, phone: contactPhone)
            self.contacts.append(contact)
            self.tableView.reloadData()
        }
        
        let cancelButton = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alertController.addAction(cancelButton)
        alertController.addAction(createButton)
        self.present(alertController, animated: true, completion: nil) }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            print("Используем старую ячейку для строки с индексом \(indexPath.row)")
            cell = reuseCell
        } else {
            print("Создаем новую ячейку для строки с индексом \(indexPath.row)")
            cell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        }
        configure(cell: &cell, for: indexPath)
        return cell
    }
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        if #available(iOS 14, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = contacts[indexPath.row].title
            configuration.secondaryText = contacts[indexPath.row].phone
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = contacts[indexPath.row].title
        }
    }
    private func loadContacts() {
        contacts = storage.load()
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDelete = UIContextualAction(style: .destructive, title: "Удалить") { _,_,_ in
            self.contacts.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}

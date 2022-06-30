//
//  ViewController.swift
//  Project7
//
//  Created by TwoStraws on 15/08/2016.
//  Copyright © 2016 Paul Hudson. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
	var petitions = [Petition]()

	override func viewDidLoad() {
		super.viewDidLoad()

        loadData()
	}
    
    func loadData() {
        let urlString: String
        
        let btnData = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showCredits))
        let btnSearch = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(promptFilterData))
        let btnReload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadData))
        navigationItem.rightBarButtonItems = [btnReload, btnSearch, btnData]

        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }

        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }

        showError("Loading error", "There was a problem loading the feed; please check your connection and try again.")
    }
    
    @objc func reloadData() {
            self.loadData()
    }
    
    @objc func promptFilterData() {
        let ac = UIAlertController(title: "Filter For Title", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let filterText = UIAlertAction(title: "Confirmar", style: .default) {
            [weak self, weak ac] action in
            guard let text = ac?.textFields?[0].text else { return }
            
            self?.filterData(text)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(filterText)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func filterData(_ filter: String){
        var petitionsTemp = [Petition]()
        
        for i in petitions {
            if i.title.contains(filter) {
                petitionsTemp.insert(i, at: 0)
            }
        }
        
        if petitionsTemp.isEmpty {
            showError("Not Found", "Sorry, data not found.")
            return
        }
        
        self.petitions.removeAll()
        tableView.reloadData()

        for x in petitionsTemp {
            self.petitions.insert(x, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }

    }
    
    @objc func showCredits() {
        let vc = UIAlertController(title: "Information", message: "The data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(vc, animated: true)
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()

        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return petitions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = DetailViewController()
		vc.detailItem = petitions[indexPath.row]
		navigationController?.pushViewController(vc, animated: true)
	}

    func showError(_ title: String, _ message: String) {
		let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
		ac.addAction(UIAlertAction(title: "OK", style: .default))
		present(ac, animated: true)
	}
}


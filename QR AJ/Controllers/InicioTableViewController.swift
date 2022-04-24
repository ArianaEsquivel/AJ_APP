//
//  InicioTableViewController.swift
//  QR AJ
//
//  Created by Ariana Esquivel on 22/04/22.
//

import UIKit


var optionsMenu = ["Perfil", "Lista de cámaras", "Agregar cámara"]
var seguesMenu =  ["showPerfil", "showListaCamaras", "showAgregarCamara"]


class MenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        return
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
    }

}


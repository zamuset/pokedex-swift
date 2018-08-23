//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Samuel Chavez on 05/02/18.
//  Copyright © 2018 Samuel Chavez. All rights reserved.
//

import UIKit

class PokemonDetailViewController: UIViewController {

    var pokemon: Pokemon!
    
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var defenseLbl: UILabel!
    
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var pokedexLbl: UILabel!
    @IBOutlet weak var weightLbl: UILabel!
    @IBOutlet weak var attackLbl: UILabel!
    
    @IBOutlet weak var evoLbl: UILabel!
    @IBOutlet weak var currEvoImg: UIImageView!
    @IBOutlet weak var nextEvoImg: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image =  UIImage(named: "\(pokemon.pokedexInt)")
        let imageNextEvo =  UIImage(named: "\(pokemon.pokedexInt + 1)")
        mainImage.image = image
        currEvoImg.image = image
        nextEvoImg.image = imageNextEvo
        
        pokemon.downloadPokemonDetails {
            self.updateUI()
        }
        
    }
    
    func updateUI(){
        descriptionText.text = pokemon.description
        
        typeLbl.text = pokemon.type
        defenseLbl.text = pokemon.defense
        
        heightLbl.text = pokemon.height
        pokedexLbl.text = "\(pokemon.pokedexInt)"
        weightLbl.text = pokemon.weight
        attackLbl.text = pokemon.attack
        
        evoLbl.text = pokemon.nextEvolutionTxt3
        print(pokemon.nextEvolutionTxt3)
        
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

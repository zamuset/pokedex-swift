//
//  Pokemon.swift
//  Pokedex
//
//  Created by Samuel Chavez on 01/02/18.
//  Copyright © 2018 Samuel Chavez. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name : String!
    private var _pokedexId : Int!
    private var _description : String!
    private var _type : String!
    private var _defense : String!
    private var _height : String!
    private var _weight : String!
    private var _attack : String!
    private var _nextEvolutionTxt2 : String!
    private var _nextEvolutionTxt3 : String!
    private var _evoImageID2 : String!
    private var _evoImageID3 : String!
    
    private var _pokemonURL : String!
    
    var name : String {
        return _name
    }
    
    var pokedexInt : Int {
        return _pokedexId
    }
    
    var description : String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var type : String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var defense : String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var height : String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    
    var weight : String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var attack : String {
        if _attack == nil {
            _attack = ""
        }
        return _attack
    }
    
    var nextEvolutionTxt2 : String {
        if _nextEvolutionTxt2 == nil {
            _nextEvolutionTxt2 = ""
        }
        return _nextEvolutionTxt2
    }
    
    var nextEvolutionTxt3 : String {
        if _nextEvolutionTxt3 == nil {
            _nextEvolutionTxt3 = ""
        }
        return _nextEvolutionTxt3
    }
    
    init(name: String, pokedexId: Int){
        self._name = name
        self._pokedexId = pokedexId
        self._pokemonURL = "\(URL_BASE)\(URL_POKEMON)\(pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        
        Alamofire.request(_pokemonURL).responseJSON { (response) in
            print("pokemon request ", self._pokemonURL)
            print("pokemon response ", response.value ?? response.error ?? "No value")
            
            if let dict = response.result.value as? Dictionary<String, AnyObject> {
                
                if let weight = dict["weight"] as? Int {
                    
                    self._weight = "\(weight)"
                    
                }
                
                if let height = dict["height"] as? Int {
                    
                    self._height = "\(height)"
                    
                }
                
                //Download Attack and Defense - for v2 API
                
                if let statsDict = dict["stats"] as? [Dictionary <String, AnyObject>] , statsDict.count > 0  {
                    
                    if let statDes = statsDict[0]["stat"]?["name"]! {
                        
                        self._attack = ("\(statDes)")
                        
                    }
                    
                    for x in 0..<statsDict.count {
                        
                        if let statDes = statsDict[x]["stat"]?["name"]! {
                            
                            if "\(statDes)" == "defense" {
                                
                                if let defenseInt = statsDict[x]["base_stat"] {
                                    
                                    self._defense  = "\(defenseInt)"
                                    
                                }
                                
                            }
                            
                            if "\(statDes)" == "attack" {
                                
                                if let attackInt = statsDict[x]["base_stat"] {
                                    
                                    self._attack  = "\(attackInt)"
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                //Download Type - for v2 API
                
                if let typesDict = dict["types"] as? [Dictionary <String, AnyObject>] , typesDict.count > 0  {
                    
                    if let typeDes = typesDict[0]["type"]!["name"]! {
                        
                        self._type = ("\(typeDes)")
                        
                    }
                    
                    for x in 1..<typesDict.count {
                        
                        if let typeDes = typesDict[x]["type"]!["name"]! {
                            
                            self._type! += "/\(typeDes)"
                            
                        }
                        
                    }
                    
                }
                
                self._type = self._type.capitalized
                
                
                
                //Download Description for v2 API
                
                let speciesURL = URL_BASE + URL_SPECIES + "\(self.pokedexInt)"
                
                Alamofire.request(speciesURL).responseJSON { (response) in
                    print("species request ", speciesURL)
                    print("species response ", response.value ?? response.error ?? "No value")
                    
                    if let descDict = response.result.value as? Dictionary<String, AnyObject> {
                        
                        if let flavourDict = descDict["flavor_text_entries"] as? [Dictionary <String, AnyObject>] , descDict.count > 0 {
                            
                            //Find the english language description - the array isn't consistent between pokemon - eg Bulbasaur and Pikach
                            
                            var x : Int = 0
                            
                            while x < flavourDict.count {
                                
                                if let language = flavourDict[x]["language"]!["name"]! {
                                    
                                    //if we find an english match, then do the following:
                                    
                                    if "\(language)" == "en" {
                                        
                                        if let detailDescription = flavourDict[x]["flavor_text"] {
                                            
                                            self._description = "\(detailDescription)"
                                            
                                            //minor text editing to imrpove readability
                                            
                                            let trimmed = self._description.replacingOccurrences(of: "\n", with: " ", options: .regularExpression)
                                            
                                            self._description = self._description.replacingOccurrences(of: "POKMON", with: "Pokémon", options: .regularExpression)
                                            
                                            self._description = self._description.replacingOccurrences(of: ".", with: ". ", options: .regularExpression)
                                            
                                            self._description = self._description.replacingOccurrences(of: ",", with: ", ", options: .regularExpression)
                                            
                                            self._description = trimmed
                                            
                                            //increment the counter beyond the max number of languages in the response to break out of the loop as we have a match
                                            
                                            x = x + 100
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                                x = x + 1
                                
                            }
                            
                        }
                        
                    }
                    
                    //Now get the evolution URL from the current URL
                    
                    if let evoURLDict = response.result.value as? Dictionary<String, AnyObject> {
                        
                        if let evoURLRaw = evoURLDict["evolution_chain"]!["url"]! {
                            
                            let evoURL = "\(evoURLRaw)"
                            
                            //Now request the relative evolution URL
                            
                            Alamofire.request(evoURL).responseJSON { (response) in
                                
                                //pass into dictionary
                                
                                if let evoInfoDict = response.result.value as? Dictionary<String, AnyObject> {
                                    
                                    //As the evolves to item is an array, we need to cast it as an array of dictionaries - note square brackets below
                                    
                                    if let evoInfoEvolvesBranchDict = evoInfoDict["chain"]!["evolves_to"] as? [Dictionary <String, AnyObject>] , evoInfoDict.count > 0 {
                                        
                                        var y : Int = 0
                                        
                                        var z : Int = 0
                                        
                                        while y < evoInfoEvolvesBranchDict.count {
                                            
                                            if let evolution2 = evoInfoEvolvesBranchDict[y]["species"]!["name"]! {
                                                
                                                self._nextEvolutionTxt2 = "\(evolution2)"
                                                
                                                self._nextEvolutionTxt2 = self._nextEvolutionTxt2.capitalized
                                                
                                                self._nextEvolutionTxt2 = "Evolution: " + self._nextEvolutionTxt2.capitalized
                                                
                                                //Now get the pokedexID we need for the image
                                                
                                                if let pokedexIdURL = evoInfoEvolvesBranchDict[y]["species"]!["url"]! {
                                                    
                                                    let evoString2 = (pokedexIdURL as AnyObject).replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                                    
                                                    self._evoImageID2 = (evoString2 as AnyObject).replacingOccurrences(of: "/", with: "")
                                                    
                                                    z = y
                                                    
                                                    y = y + 100
                                                    
                                                }
                                                
                                            }
                                            
                                            //For second evolution, also need to access it as an array
                                            
                                            if let evolution2 = evoInfoEvolvesBranchDict[z]["evolves_to"]! as? [Dictionary <String, AnyObject>] , evoInfoEvolvesBranchDict.count > 0 {
                                                
                                                if evolution2.count > 0 {
                                                    
                                                    if let evolution3 = evolution2[z]["species"]!["name"]! {
                                                        
                                                        self._nextEvolutionTxt3 = "\(evolution3)"
                                                        
                                                        self._nextEvolutionTxt3 = self._nextEvolutionTxt3.capitalized
                                                        
                                                        self._nextEvolutionTxt3 = " / " + self._nextEvolutionTxt3
                                                        
                                                        if let pokedexIdURL = evolution2[z]["species"]!["url"]! {
                                                            
                                                            var evoString3 = (pokedexIdURL as AnyObject).replacingOccurrences(of: "https://pokeapi.co/api/v2/pokemon-species/", with: "")
                                                            
                                                            evoString3 = (evoString3 as AnyObject).replacingOccurrences(of: "/", with: "")
                                                            
                                                            self._evoImageID3 = (evoString3 as AnyObject).replacingOccurrences(of: "/", with: "")
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                                
                                            else {
                                                
                                                self._nextEvolutionTxt3 = ""
                                                
                                                self._evoImageID3 = nil
                                                
                                            }
                                            
                                            y = y + 1
                                            
                                        }
                                        
                                    }  else  {
                                        
                                        self._nextEvolutionTxt2 = "No further evolutions"
                                        
                                        self._evoImageID2 = nil
                                        
                                    }
                                    
                                }
                                
                                completed()
                                
                            } // close alamofire
                            
                        }
                        
                    }
                    
                    
                    
                } // close alamofire
                
                completed()
                
            }
            
            completed()
            
        } //end func download poke malarky
        
    } // this is the end!
    
}

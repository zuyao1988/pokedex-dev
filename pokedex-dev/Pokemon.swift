//
//  Pokemon.swift
//  pokedex-dev
//
//  Created by Zu Yao on 9/3/16.
//  Copyright © 2016 Zu Yao. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLvl: String!
    private var _pokemonUrl: String!
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var description: String {
        if _description == nil {
            _description = "???"
        }
        return _description
    }
    
    var type: String {
        get {
            if _type == nil {
                _type = "???"
            }
            return _type
        }
    }
    
    var defense: String {
        if _defense == nil {
            _defense = "???"
        }
        return _defense
    }
    
    var height: String {
        if _height == nil {
            _height = "???"
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = "???"
        }
        return _weight
    }
    
    var attack: String {
        if _attack == nil {
            _attack = "???"
        }
        return _attack
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLvl: String {
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        return _nextEvolutionLvl
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        self._pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        let url = NSURL(string: _pokemonUrl)!
        Alamofire.request(.GET, url).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                if let height = dict["height"] as? String {
                    self._height = height
                }
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                if let types = dict["types"] as? [Dictionary<String, String>] where types.count > 0 {
//                    if let name = types[0]["name"] {
//                        self._type = name
//                    }
//                    
//                    if types.count > 1 {
//                        for var x = 1; x < types.count; x++ {
//                            if let name = types[x]["name"] {
//                                self._type! += "/\(name)"
//                            }
//                        }
//                    }
                    
                    var typesOnly = [String]()
                    for type in types {
                        if let name = type["name"] {
                            typesOnly.append(name.capitalizedString)
                        }
                    }
                    self._type = typesOnly.joinWithSeparator("/")
                }
                
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                    if let url = descArr[0]["resource_uri"] {
                        let nsurl = NSURL(string: "\(URL_BASE)\(url)")!
                        Alamofire.request(.GET, nsurl).responseJSON { response in
                            let desResult = response.result
                            if let desDict = desResult.value as? Dictionary<String, AnyObject> {
                                if let description = desDict["description"] as? String {
                                    self._description = description
                                    print("///", self._description)
                                }
                            }
                            completed()
                        }
                    }
                } else {
                    self._description = ""
                }
                
                if let evolution = dict["evolutions"] as? [Dictionary<String, AnyObject>] where evolution.count > 0 {
                    if let to = evolution[0]["to"] as? String {
                        //exclude mega pokemon
//                        if to.rangeOfString("mega").location == NSNotFound {
                        if to.rangeOfString("mega") == nil {
                            if let uri = evolution[0]["resource_uri"] as? String {
                                let newStr = uri.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                                let num = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                                self._nextEvolutionId = num
                                self._nextEvolutionTxt = to
                                
                                if let lvl = evolution[0]["level"] as? Int {
                                    self._nextEvolutionLvl = "\(lvl)"
                                }
                                print(self._nextEvolutionLvl)
                                print(self._nextEvolutionId)
                                print(self._nextEvolutionTxt)
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    
}
//
//  EventEmitting.swift
//  iForest
//
//  Created by Marcel Mravec on 05.09.2024.
//

import Combine

protocol EventEmitting {
    associatedtype Event
    
    var eventPublisher: AnyPublisher<Event, Never> { get }
}

//
//  MDSDocumentStorage.swift
//  Mini Document Storage
//
//  Created by Stevo on 10/9/18.
//  Copyright © 2018 Stevo Brock. All rights reserved.
//

import Foundation

//----------------------------------------------------------------------------------------------------------------------
// MARK: MDSBatchResult
public enum MDSBatchResult {
	case commit
	case cancel
}

//----------------------------------------------------------------------------------------------------------------------
// MARK: - MDSDocumentStorage protocol
public protocol MDSDocumentStorage : class {

	// MARK: Properties
	var	id :String { get }

	// MARK: Instance methods
	func extraValue<T>(for key :String) -> T?
	func store<T>(extraValue :T?, for key :String)

	func newDocument<T : MDSDocument>(creationProc :(_ id :String, _ documentStorage :MDSDocumentStorage) -> T) -> T

	func document<T : MDSDocument>(for documentID :String) -> T?

	func creationDate(for document :MDSDocument) -> Date
	func modificationDate(for document :MDSDocument) -> Date

	func value(for property :String, in document :MDSDocument) -> Any?
	func date(for property :String, in document :MDSDocument) -> Date?
	func set<T : MDSDocument>(_ value :Any?, for property :String, in document :T)

	func remove(_ document :MDSDocument)

	func enumerate<T : MDSDocument>(proc :(_ document : T) -> Void)
	func enumerate<T : MDSDocument>(documentIDs :[String], proc :(_ document : T) -> Void)

	func batch(_ proc :() throws -> MDSBatchResult) rethrows

	func registerCollection<T : MDSDocument>(named name :String, version :UInt, relevantProperties :[String],
			info :[String : Any], isUpToDate :Bool, includeSelector :String,
			includeProc :@escaping (_ document :T, _ info :[String : Any]) -> Bool)
	func queryCollectionDocumentCount(name :String) -> UInt
	func enumerateCollection<T : MDSDocument>(name :String, proc :(_ document : T) -> Void)

	func registerIndex<T : MDSDocument>(named name :String, version :UInt, relevantProperties :[String],
			isUpToDate :Bool, keysSelector :String, keysProc :@escaping (_ document :T) -> [String])
	func enumerateIndex<T : MDSDocument>(name :String, keys :[String], proc :(_ key :String, _ document :T) -> Void)
}

//----------------------------------------------------------------------------------------------------------------------
// MARK: - MDSDocumentStorage extension
extension MDSDocumentStorage {

	// MARK: Instance methods
	//------------------------------------------------------------------------------------------------------------------
	public func newDocument<T : MDSDocument>() -> T { return newDocument() { return T(id: $0, documentStorage: $1) } }

	//------------------------------------------------------------------------------------------------------------------
	public func documents<T :MDSDocument>() -> [T] {
		// Setup
		var	documents = [T]()

		// Enumerate all documents
		enumerate(proc: { (document :T) -> Void in documents.append(document) })

		return documents
	}

	//------------------------------------------------------------------------------------------------------------------
	public func documents<T :MDSDocument>(for documentIDs :[String]) -> [T] {
		// Setup
		var	documents = [T]()

		// Enumerate documents for document ids
		enumerate(documentIDs: documentIDs, proc: { (document :T) -> Void in documents.append(document) })

		return documents
	}

	//------------------------------------------------------------------------------------------------------------------
	public func registerCollection<T : MDSDocument>(named name :String, version :UInt = 1, relevantProperties :[String],
			info :[String : Any] = [:], isUpToDate :Bool = false, includeSelector :String = "",
			includeProc :@escaping (_ document :T, _ info :[String : Any]) -> Bool) {
		// Register collection
		registerCollection(named: name, version: version, relevantProperties: relevantProperties,
				info: info, isUpToDate: isUpToDate, includeSelector: includeSelector, includeProc: includeProc)
	}

	//------------------------------------------------------------------------------------------------------------------
	public func registerIndex<T : MDSDocument>(named name :String, version :UInt = 1, relevantProperties :[String],
			isUpToDate :Bool = false, keysSelector :String = "", keysProc :@escaping (_ document :T) -> [String]) {
		// Register index
		registerIndex(named: name, version: version, relevantProperties: relevantProperties, isUpToDate: isUpToDate,
				keysSelector: keysSelector, keysProc: keysProc)
	}

	//------------------------------------------------------------------------------------------------------------------
	public func documentMap<T : MDSDocument>(forIndexNamed name :String, keys :[String]) -> [String : T] {
		// Setup
		var	documentMap = [String : T]()

		enumerateIndex(name: name, keys: keys) { (key :String, document :T) in documentMap[key] = document }

		return documentMap
	}
}

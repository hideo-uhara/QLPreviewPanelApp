//
// UncheckedSendable.swift
//

import Foundation

struct UncheckedSendable<T>: @unchecked Sendable {
	let value: T
}


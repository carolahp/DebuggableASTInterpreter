Class {
	#name : #DASTStackTests,
	#superclass : #TestCase,
	#category : 'DebuggableASTInterpreter-Tests'
}

{ #category : #tests }
DASTStackTests >> testAsArray [
	| dstack stack |
	dstack := DASTStack new.
	dstack push: 1; push: 2; push:3.
	stack := Stack new.
	stack push: 1; push: 2; push:3.
	self assert: stack asArray equals: dstack asArray
]

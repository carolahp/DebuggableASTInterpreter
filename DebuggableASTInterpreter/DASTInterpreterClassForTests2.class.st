Class {
	#name : #DASTInterpreterClassForTests2,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#category : 'DebuggableASTInterpreter-TestsClasses'
}

{ #category : #initialization }
DASTInterpreterClassForTests2 >> evaluateBlock: aBlock [
	^aBlock value
]

{ #category : #initialization }
DASTInterpreterClassForTests2 >> initialize [ 
	super initialize.
	x := 69
]

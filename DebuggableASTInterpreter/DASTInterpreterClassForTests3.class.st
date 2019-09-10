Class {
	#name : #DASTInterpreterClassForTests3,
	#superclass : #Object,
	#instVars : [
		'x'
	],
	#classVars : [
		'classVar'
	],
	#classInstVars : [
		'ivClassSide'
	],
	#category : #'DebuggableASTInterpreter-TestsClasses'
}

{ #category : #initialization }
DASTInterpreterClassForTests3 >> evaluateBlock [
	^self evaluateBlock: [ x ]
]

{ #category : #initialization }
DASTInterpreterClassForTests3 >> evaluateBlock: aBlock [
	^DASTInterpreterClassForTests2 new evaluateBlock: aBlock
]

{ #category : #initialization }
DASTInterpreterClassForTests3 >> getClassVariable [
	^ classVar
]

{ #category : #initialization }
DASTInterpreterClassForTests3 >> initialize [
	super initialize.
	x := 123
]

{ #category : #initialization }
DASTInterpreterClassForTests3 >> setClassVariable [
	classVar := 42
]

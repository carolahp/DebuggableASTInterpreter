Class {
	#name : #DASTContext,
	#superclass : #Object,
	#instVars : [
		'variablesDict',
		'parentContext'
	],
	#category : #DebuggableASTInterpreter
}

{ #category : #accessing }
DASTContext >> at: aByteSymbol put: anObject [
	"store variable and its value"
	variablesDict at: aByteSymbol put: anObject
]

{ #category : #accessing }
DASTContext >> initialize [
	super initialize.
	variablesDict := Dictionary new
]

{ #category : #accessing }
DASTContext >> initializeInContext: aDASTContext [
	"initializes an empty context whose parent is aDASTContext"
	parentContext := aDASTContext
]

{ #category : #accessing }
DASTContext >> parentContext [
	^ parentContext
]

{ #category : #accessing }
DASTContext >> variablesDict [
	^ variablesDict
]
Class {
	#name : #DASTInterpreterClassForTests6,
	#superclass : #Object,
	#instVars : [
		'iv1',
		'iv2'
	],
	#category : 'DebuggableASTInterpreter-TestsClasses'
}

{ #category : #initialization }
DASTInterpreterClassForTests6 >> initializeIV1: aValue1 IV2: aValue2 [
	iv1 := aValue1.
	iv2 := aValue2.
]

{ #category : #accessing }
DASTInterpreterClassForTests6 >> iv1 [
	^ iv1
]

{ #category : #accessing }
DASTInterpreterClassForTests6 >> iv1: anObject [
	iv1 := anObject
]

{ #category : #accessing }
DASTInterpreterClassForTests6 >> iv2 [
	^ iv2
]

{ #category : #accessing }
DASTInterpreterClassForTests6 >> iv2: anObject [
	iv2 := anObject
]

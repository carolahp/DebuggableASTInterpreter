Class {
	#name : #DASTInterpreterClassForTests4,
	#superclass : #DASTInterpreterClassForTests5,
	#category : #'DebuggableASTInterpreter-TestsClasses'
}

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests4 >> getClassVar5 [
	^ classVar5 ifNil: [ classVar5 := 5 ]
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests4 >> m1 [
	^super m1
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests4 >> m2 [
	^42
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests4 >> methodWithLocalVarZSetAs5AndThatReturns43 [
	| z |
	z := 5.
	^ 42
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests4 >> setClassVar5: aValue [
	^ classVar5 := 5
]

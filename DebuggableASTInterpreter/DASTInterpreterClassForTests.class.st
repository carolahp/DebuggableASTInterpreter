Class {
	#name : #DASTInterpreterClassForTests,
	#superclass : #Object,
	#instVars : [
		'block'
	],
	#category : 'DebuggableASTInterpreter-TestsClasses'
}

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> assignateArgumentToLocalVar: anArgument [
	| x |
	x := anArgument.
	^ x
	 
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> assignateArgumentToLocalVarInsideBlock: anArgument [
	| x |
	true ifTrue: [ x := anArgument ].
	^ x
	 
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> blockAsParameter: aBlock [
	^ aBlock value: 3
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> evaluateBlock: aBlock [
	|t| 
	t := nil.
	^ aBlock value.
]

{ #category : #tests }
DASTInterpreterClassForTests >> evaluateBlockAndIgnoreArgument: arg [
	^ block value
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getBlockThatAccessesVariableTSetAs42 [
	| t |
	t := 42.
	^ [ t ]
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getBlockThatEvaluatesConstant42 [
	^ [ 42 ]
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getBlockThatReturns32 [
	^ [ ^ 32 ]
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getBlockThatReturns32EvaluatedInThisContext [
	^ [ ^ 32 ] value
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getBlockWithParameter [
	^ [ :e | e ] value: 123
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getTwoBlocksArray [
	| a |
	a := 0.
	^ {[ a := 2] . [a]}
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> getVariableDeclaredInMethod [
	| a |
	[ a := 0 ] value.
	^ a
]

{ #category : #tests }
DASTInterpreterClassForTests >> initialize [ 
	|x|
	super initialize.
	x := 123
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> jumpingOut [
	
	#(1 2 3 4 5) do: [:each |
		each = 3
			ifTrue: [^ 3]].
	^ 42
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> methodEmpty [
	
]

{ #category : #tests }
DASTInterpreterClassForTests >> methodPrimitive9999ThatDoesntExist [
	<primitive: 9999>
	^ true
	
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> setVariableAndDefineBlock2 [
	| t |
	t := 42.
	^ self evaluateBlock: [ t := 33 . t ]
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> setVariableAndDefineBlock3 [
	| t |
	t := 42.
	^{ self evaluateBlock: [ t := 33 . t ] .
		self evaluateBlock: [ t ] .
		self evaluateBlock: [ t := 66 . t ] .
		self evaluateBlock: [ t ] } 
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> setVariableAndDefineBlock4 [
	| t block |
	"variable lookup is done at excecution time"
	t := 42.
	block := [ t ].
	t := 69.
	^ self evaluateBlock: block
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> signalException [
	^  1 / 0
]

{ #category : #tests }
DASTInterpreterClassForTests >> testArg: arg [
	block := [ arg ].
	^ self evaluateBlockAndIgnoreArgument: 'zork'
]

{ #category : #'as yet unclassified' }
DASTInterpreterClassForTests >> testExplicitReturn [
	|a|
	a := 1.
	0 isZero ifTrue: [ ^ a ].
	a := 2.
	^ a
]

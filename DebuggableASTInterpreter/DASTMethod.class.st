Class {
	#name : #DASTMethod,
	#superclass : #DASTClosure,
	#instVars : [
		'evaluatePrimitive',
		'evaluator'
	],
	#category : #'DebuggableASTInterpreter-Closures'
}

{ #category : #'gt-inspector-extension' }
DASTMethod >> bodyOffset [
	^ self selectorFormatted size "+ (self isNoMethod ifTrue: [ 1 ] ifFalse: [ 0 ])"
]

{ #category : #accessing }
DASTMethod >> evaluatePrimitive [
	^ evaluatePrimitive ifNil: [ evaluatePrimitive := true ]
]

{ #category : #accessing }
DASTMethod >> evaluatePrimitive: aBoolean [
	^ evaluatePrimitive := false
]

{ #category : #'gt-inspector-extension' }
DASTMethod >> gtInspectorIn: composite [
	<gtInspectorPresentationOrder: 5>
	^ composite text
		title: 'source';
		display:
				[ self sourceCodeWithClassAndSelector ];
		when: [ true ]
]

{ #category : #'gt-inspector-extension' }
DASTMethod >> gtInspectorIn: composite highlightInterval: anInterval [
	^composite text
		title: 'Source with Interval';
		display: [ self sourceCodeWithClassAndSelector	 ];
		initialize: [ :presentation | 

			presentation selectionInterval: anInterval];
		when: [ true ]
]

{ #category : #accessing }
DASTMethod >> initializeWith: aRBNode [ 
	self deprecated: 'use initializeWith:evaluator:'.
	self assert: aRBNode isBlock not.
	super initializeWith:  aRBNode 
]

{ #category : #accessing }
DASTMethod >> initializeWith: aRBNode evaluator: anEvaluator [
	evaluator := anEvaluator.
	self assert: aRBNode isBlock not.
	super initializeWith:  aRBNode 
]

{ #category : #accessing }
DASTMethod >> isBlock [ 
	^ false
]

{ #category : #accessing }
DASTMethod >> isEnsure [
	^ nodeAST primitive = 198
]

{ #category : #testing }
DASTMethod >> isMessageValue [
	^ self isPrimitive 
		and: [ (201 to: 206) includes: self primitive ]
]

{ #category : #accessing }
DASTMethod >> isNamedPrimitive [
	^ self primitive = 117
]

{ #category : #testing }
DASTMethod >> isNoMethod [
	^ self selector = #noMethod 
]

{ #category : #accessing }
DASTMethod >> isOnDo [
	^ nodeAST primitive = 199
]

{ #category : #accessing }
DASTMethod >> isPrimitive [ 
	^ nodeAST isPrimitive and: [ self evaluatePrimitive ]
]

{ #category : #accessing }
DASTMethod >> methodClass [

	^ [ nodeAST methodClass ] on: Exception do: [ 
			self isNoMethod 
				ifTrue: [ ^ evaluator classOf: evaluator nilObject]
				ifFalse: [ :e | e defaultAction ] ]
]

{ #category : #accessing }
DASTMethod >> pragmas [
	^nodeAST pragmas
]

{ #category : #accessing }
DASTMethod >> primitive [ 
	^ nodeAST primitive
]

{ #category : #accessing }
DASTMethod >> selector [
	^ nodeAST selector
]

{ #category : #'gt-inspector-extension' }
DASTMethod >> selectorFormatted [
	^ (self isNoMethod ifTrue: [ self selector, Character lf asString ] ifFalse: [ '' ]) "'(' , self methodClass asString , ')>>',"
		
]

{ #category : #'gt-inspector-extension' }
DASTMethod >> sourceCodeWithClassAndSelector [
	^ self selectorFormatted , self sourceCode asString "sourceCode will contain the selector of the method at the beginning"
]

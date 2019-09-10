Class {
	#name : #DASTMethod,
	#superclass : #DASTClosure,
	#category : #'DebuggableASTInterpreter-Closures'
}

{ #category : #'gt-extension' }
DASTMethod >> bodyOffset [
	^ self selectorFormatted size "+ (self isNoMethod ifTrue: [ 0 ] ifFalse: [ 0 ])"
]

{ #category : #'gt-extension' }
DASTMethod >> gtInspectorIn: composite highlightInterval: anInterval [
	^composite text
		title: 'Source with Interval';
		display: [ self sourceCodeWithClassAndSelector	 ];
		initialize: [ :presentation | 
			presentation selectionInterval: (anInterval collect: [:each | each + self bodyOffset])];
		when: [ true ]
]

{ #category : #accessing }
DASTMethod >> initializeWith: aRBNode [ 
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

{ #category : #testing }
DASTMethod >> isNoMethod [
	^ (self methodClass = UndefinedObject) and: [ self selector = #noMethod ]
]

{ #category : #accessing }
DASTMethod >> isOnDo [
	^ nodeAST primitive = 199
]

{ #category : #accessing }
DASTMethod >> isPrimitive [ 
	^ nodeAST isPrimitive
]

{ #category : #accessing }
DASTMethod >> methodClass [
	^ [nodeAST methodClass] on: Exception do: [ nil class ]
]

{ #category : #accessing }
DASTMethod >> primitive [ 
	^ nodeAST primitive
]

{ #category : #accessing }
DASTMethod >> selector [
	^ nodeAST selector
]

{ #category : #'gt-extension' }
DASTMethod >> selectorFormatted [
	^ '(' , self methodClass asString , ')>>',
		(self isNoMethod ifTrue: [ self selector, (Character lf) asString ] ifFalse: [ '' ])
]

{ #category : #'gt-extension' }
DASTMethod >> sourceCodeWithClassAndSelector [
	^ self selectorFormatted , self sourceCode asString "sourceCode will contain the selector of the method at the beginning except for the root method noMethod"
]

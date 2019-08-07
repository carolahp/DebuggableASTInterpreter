Class {
	#name : #DASTMethod,
	#superclass : #DASTClosure,
	#instVars : [
		'evaluatePrimitive'
	],
	#category : #'DebuggableASTInterpreter-Closures'
}

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
	^composite text
		title: 'source';
		display: [ '(',self methodClass asString , ')>>', 
						self sourceCode asString
			];
		when: [ true ]
]

{ #category : #'gt-inspector-extension' }
DASTMethod >> gtInspectorIn: composite highlightInterval: anInterval [
	^composite text
		title: 'Source with Interval';
		display: [ '(',self methodClass asString , ')>>', 
						self sourceCode asString
			];
		initialize: [ :presentation | 
			presentation selectionInterval: (anInterval collect: [:each | each + ( '(',self methodClass asString , ')>>') size])];
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

{ #category : #accessing }
DASTMethod >> isNamedPrimitive [
	^ self primitive = 117
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
DASTMethod >> primitive [ 
	^ nodeAST primitive
]

{ #category : #accessing }
DASTMethod >> selector [
	^ nodeAST selector
]

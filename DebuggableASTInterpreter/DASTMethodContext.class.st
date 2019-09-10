"
I am a context created to evaluate the body of a method
"
Class {
	#name : #DASTMethodContext,
	#superclass : #DASTContext,
	#category : #'DebuggableASTInterpreter-Contexts'
}

{ #category : #initialization }
DASTMethodContext >> initializeContext [

	| compiledMethod theMethod visitor aClass aSelector |
	
	self	parent: sender.
	aSelector := messageNode selector.
	
	aClass := (self receiver isNil and: [ aSelector = #value ]) 
		ifTrue: [ self halt. BlockClosure ]
		ifFalse: [ self getClassForLookup ].
	
	compiledMethod := self lookupSelector: aSelector startInClass: aClass.
	theMethod := DASTMethod new initializeWith: compiledMethod ast.
	
	visitor := DASTPostOrderTreeVisitor new.
	theMethod body acceptVisitor: visitor.
	nodes := visitor stack.
	
	self 	methodOrBlock: theMethod;
			nodes: nodes.
	
]

{ #category : #initialization }
DASTMethodContext >> isBlockContext [ 
	^ false
]

{ #category : #testing }
DASTMethodContext >> isNoMethod [
	^ (receiver isNil and: [ closure selector = #noMethod ])
]

{ #category : #initialization }
DASTMethodContext >> isUnwindContext [
	"is this context for  method that is marked?"
	^ closure primitive = 198
]

{ #category : #initialization }
DASTMethodContext >> printOn: aStream [
	| selector class mclass  |
			closure == nil
				ifTrue: [ ^  aStream nextPutAll: 'DAST Context: initializing' ].
			self isNoMethod 
				ifTrue: [ ^  aStream nextPutAll: 'UndefinedObject>>noMethod' ].
			class := receiver class.
			mclass := closure methodClass.
			selector := closure selector ifNil: [ closure defaultSelector ].
			aStream nextPutAll: class name.
			mclass == class
				ifFalse:
					[ aStream nextPut: $(.
					aStream nextPutAll: mclass name.
					aStream nextPut: $) ].
			aStream nextPutAll: '>>'.
			aStream nextPutAll: selector.
			selector = #doesNotUnderstand:
				ifTrue:
					[ aStream space.
					(self variablesDict values at: 1) selector printOn: aStream ]
]

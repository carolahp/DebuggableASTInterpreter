"
I am a context created to evaluate the body of a block
"
Class {
	#name : #DASTBlockContext,
	#superclass : #DASTContext,
	#category : #'DebuggableASTInterpreter-Contexts'
}

{ #category : #converting }
DASTBlockContext class >> ep2RemoteClass [
	^ EP2ExternalContext 
]

{ #category : #'accessing - private' }
DASTBlockContext >> allInstVars [ 
	^ (closure outerContext allInstVars ,
	  sender allInstVars) select: [ :iv | iv isKindOf: Association ] "ugly, used to prevent adding instance variables of the block"
]

{ #category : #'accessing - private' }
DASTBlockContext >> allTemps [
	^ self variablesDict associations ,
	  closure outerContext allTemps 
]

{ #category : #converting }
DASTBlockContext >> asRemoteObjectInObjectSpace: anEP2ObjectSpace [  
	^ anEP2ObjectSpace backend contextFrom: self
]

{ #category : #initialization }
DASTBlockContext >> cast [
	super cast.

"	receiver := receiver asRemoteObjectCasted.
	variablesDict
		associationsDo:
			[ :assoc | variablesDict at: assoc key put: assoc value asRemoteObjectCasted ].
	self casted: true"
]

{ #category : #initialization }
DASTBlockContext >> contextTag [
	^ closure outerContext
]

{ #category : #'API-lookup' }
DASTBlockContext >> findLocalVariable: aName [
	^ variablesDict 
		associationAt: aName 
		ifAbsent: [ 
			(closure outerContext findLocalVariable: aName) ifNil: [ 
				(self sender findLocalVariable: aName) ifNil: [ ^ nil ]
			]
		].
		
]

{ #category : #initialization }
DASTBlockContext >> initializeContext [
	
	| visitor |
	" My receiver is the DASTBlock that received the message value (or any of its variants)"
	self	parent: receiver outerContext.
	"
	aClass := (self receiver isNil and: [ aSelector = #value ]) 
		ifTrue: [ BlockClosure ]
		ifFalse: [ self getClassForLookup ].
	"
	visitor := DASTPostOrderTreeVisitor new.
	receiver body acceptVisitor: visitor.
	nodes := visitor stack.
	currentNode := nodes top.
	self 	methodOrBlock: receiver;
			nodes: nodes.
	
]

{ #category : #initialization }
DASTBlockContext >> isBlockContext [
	^ true
]

{ #category : #initialization }
DASTBlockContext >> isUnwindContext [
	"is this context for  method that is marked?"
	^ false
]

{ #category : #initialization }
DASTBlockContext >> method [
	^ closure outerContext method
]

{ #category : #initialization }
DASTBlockContext >> printOn: aStream [
	aStream nextPutAll: closure printString , ' in '.
			closure outerContext printOn: aStream
]

{ #category : #initialization }
DASTBlockContext >> receiver [
	^ closure outerContext receiver
]

Class {
	#name : #DASTSystemEnvironment,
	#superclass : #DASTEnvironment,
	#instVars : [
		'astCache',
		'interpreter'
	],
	#category : #'DebuggableASTInterpreter-Environments'
}

{ #category : #'variables-class' }
DASTSystemEnvironment >> assignClassVariable: name inObject: anObject value: value [

	(self findClassVariable: name inObject: anObject)
		ifNotNil: [ :var | var value: value . ^ true].
	
	^ false
]

{ #category : #'variables-instance' }
DASTSystemEnvironment >> assignInstanceVariable: name inObject: anObject value: value [
	(anObject class allInstVarNames includes: name)
		ifTrue: [ anObject instVarNamed: name put: value .  ^ true].
	^ false
]

{ #category : #accessing }
DASTSystemEnvironment >> astCache [
	^ astCache
]

{ #category : #encoding }
DASTSystemEnvironment >> blockFrom: aDASTBlock [
	^ aDASTBlock
]

{ #category : #decoding }
DASTSystemEnvironment >> classOf: anObject [ 
	^ anObject class
]

{ #category : #primitives }
DASTSystemEnvironment >> executePrimitiveMethod: aDASTMethod withArguments: aCollection [ 
	self shouldBeImplemented.
]

{ #category : #primitives }
DASTSystemEnvironment >> executePrimitiveMethod: aDASTMethod withReceiver: anObject withArguments: aCollection [ 
	^ anObject tryPrimitive: aDASTMethod primitive withArgs: aCollection  
]

{ #category : #'variables-class' }
DASTSystemEnvironment >> findClassVariable: aName inObject: anObject [
	
	^ anObject isClass 
		ifTrue: [ anObject innerBindingOf: aName ]
		ifFalse:[ anObject class innerBindingOf: aName ] 
	
]

{ #category : #'variables-class' }
DASTSystemEnvironment >> findClassVariable: aName inObjectAndItsParents: anObject [
	| objclass objparent |
	objclass := anObject isClass 
		ifTrue: [ anObject ]
		ifFalse:[ anObject class ].
	
	
	objparent := objclass.
	[ objparent ] whileNotNil: [ 
		(objparent innerBindingOf: aName) ifNotNil: [:assoc | ^ assoc].
		objparent := objparent superclass.
		 ].
	^ nil
]

{ #category : #'variables - global' }
DASTSystemEnvironment >> findGlobalVariable: aString [ 
	^ aString -> (Smalltalk globals at: aString ifAbsent: [
self error: 'Variable ', aString , ' not defined!'
])
]

{ #category : #'variables-instance' }
DASTSystemEnvironment >> findInstanceVariable: aString inObject: anObject [ 
	^ [ anObject instVarNamed: aString ]
		on: InstanceVariableNotFound do: [ nil ] 
]

{ #category : #initialize }
DASTSystemEnvironment >> initialize [
	super initialize.
	astCache := IdentityDictionary new
]

{ #category : #accessing }
DASTSystemEnvironment >> interpreter [
	^ interpreter
]

{ #category : #accessing }
DASTSystemEnvironment >> interpreter: aDASTInterpreter [ 
	interpreter := aDASTInterpreter
]

{ #category : #testing }
DASTSystemEnvironment >> isEPDASTBlockMirror: anObject [
	^ anObject isBlock
]

{ #category : #encoding }
DASTSystemEnvironment >> literalFrom: anInteger [ 
	^ anInteger
]

{ #category : #encoding }
DASTSystemEnvironment >> newArrayWithAll: aCollection [ 
	^ aCollection asArray
]

{ #category : #accessing }
DASTSystemEnvironment >> nilObject [
	^ nil
]

{ #category : #testing }
DASTSystemEnvironment >> primitiveResultIsError: anObject [ 
	"result hasFailed"
	^ (anObject isKindOf: Array ) and: [(anObject at: 1 ifAbsent: nil) = Context primitiveFailToken first ]
]

{ #category : #primitive }
DASTSystemEnvironment >> primitiveResultValue: anObject [
	^ anObject
]

{ #category : #decoding }
DASTSystemEnvironment >> valueOf: anObject [ 
	^ anObject
]

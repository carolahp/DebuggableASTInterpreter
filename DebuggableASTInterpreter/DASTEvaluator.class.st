Class {
	#name : #DASTEvaluator,
	#superclass : #EPASTEvaluator,
	#instVars : [
		'interpreter'
	],
	#category : #'DebuggableASTInterpreter-Espell'
}

{ #category : #'variables-class' }
DASTEvaluator >> assignClassVariable: name inObject: anObject value: value [
	| rgClass |
	
	(self findClassVariable: name inObject: anObject) ifNotNil: [ 
		:var | 
		var value: value. ^ true
		"| rDictionary |
			rDictionary := EPRemoteDictionary on: anObject basicClass classPool. 
			rDictionary at: name put: value " 
		]. 

	^ false
]

{ #category : #'variables-instance' }
DASTEvaluator >> assignInstanceVariable: name inObject: anObject value: value [
	| rgClass |
	rgClass := anObject basicClass asRGClass.
	(rgClass allInstVarNames includes: name)
		ifTrue: [ |ivIndex| 
			ivIndex := rgClass instVarIndexFor: name ifAbsent: [ self halt ].
			anObject instanceVariableAtIndex: ivIndex put: value. 
			^ true].
	^ false
]

{ #category : #accessing }
DASTEvaluator >> astCache [
	^ astCache
]

{ #category : #encoding }
DASTEvaluator >> blockFrom: aDASTBlock [
	^ (self objectSpace backend mirrorOnExternalHandle: aDASTBlock) asDASTBlockMirror
]

{ #category : #interpreting }
DASTEvaluator >> evaluateAST: ast [
	
	^ self evaluateAST: ast withTemps: #() 
]

{ #category : #interpreting }
DASTEvaluator >> evaluateCode: someCode withTemps: aCollectionOfTemps [
	
	^self evaluateAST: (self parse: someCode) withTemps: aCollectionOfTemps 
]

{ #category : #primitives }
DASTEvaluator >> executePrimitiveMethod: aDASTMethod withReceiver: anEPMirror withArguments: aCollection [ 
	^ anEPMirror executePrimitiveMethod: aDASTMethod withArguments: aCollection asArray
]

{ #category : #'variables-class' }
DASTEvaluator >> findClassVariable: aString inObject: anObject [ 
	| mClass hlClass |
	mClass := anObject isClassMirror
		ifTrue: [ anObject asClassMirror ]
		ifFalse: [ anObject basicClass ].
	hlClass := mClass asRemoteClassOnEnvironment: (EPRemoteEnvironment on: self environment bootstrapEnvironment).
	
	^ hlClass innerBindingOf: aString.
]

{ #category : #'variables-class' }
DASTEvaluator >> findClassVariable: aName inObjectAndItsParents: anObject [
	| mobjclass hobjclass hobjparent |
	
	mobjclass := anObject isClassMirror
		ifTrue: [ anObject asClassMirror ]
		ifFalse: [ anObject basicClass ].
	hobjclass := mobjclass asRemoteClassOnEnvironment: (EPRemoteEnvironment on: self environment bootstrapEnvironment).

	hobjparent := hobjclass.
	[ hobjparent isNilObject ] whileFalse: [ 
		(hobjparent innerBindingOf: aName) ifNotNil: [:assoc | ^ assoc].
		hobjparent := hobjparent superclass.
		 ].
	^ nil
	
]

{ #category : #'variables-global' }
DASTEvaluator >> findGlobalVariable: aString [ 
	 ^(self environment bindingOf: aString) 
			ifNil: [ self error: 'Variable ', aString , ' not defined!' ] 
]

{ #category : #'variables-instance' }
DASTEvaluator >> findInstanceVariable: aName inObject: anObject [
	| rgClass |
	self flag: 'incomplete return value'.
	
	rgClass := anObject basicClass asRGClass.
	rgClass ifNil: [ ^ nil ].
	(rgClass allInstVarNames includes: aName)
		ifTrue: [ |ivIndex| 
			ivIndex := rgClass instVarIndexFor: aName ifAbsent: [ self halt ].
			^ anObject instanceVariableAtIndex: ivIndex ].
	^ nil
]

{ #category : #interpreting }
DASTEvaluator >> initialize [

	super initialize.
	interpreterClass := DASTInterpreter.
	astCache := IdentityDictionary new.
	
]

{ #category : #accessing }
DASTEvaluator >> interpreter [
	^ interpreter ifNil: [ self newInterpreter ]
]

{ #category : #testing }
DASTEvaluator >> isEPDASTBlockMirror: anEPMirror [ 
	^ anEPMirror isEPDASTBlockMirror
]

{ #category : #encoding }
DASTEvaluator >> literalFrom: anObject [ 
	^ anObject asLiteralInObjectSpace: self objectSpace
]

{ #category : #encoding }
DASTEvaluator >> newArrayWithAll: aCollection [ 
	^ self objectSpace newArrayWithAll: aCollection
]

{ #category : #accessing }
DASTEvaluator >> newInterpreter [
	^ interpreter := super newInterpreter
	
]

{ #category : #accessing }
DASTEvaluator >> nilObject [
	^ objectSpace backend nilObject
]

{ #category : #parsing }
DASTEvaluator >> parse: aString [
	| expression |
	
	expression := RBParser parseExpression: aString.
	(expression isSequence and: [ environment classLoader isClassDefinition: aString ])
		ifTrue: [ expression := EPASTClassDefinition fromMessageNode: expression ].
	(expression isMessage and: [ self isTraitDefinitionSelector: expression selector ])
		ifTrue: [ expression := EPASTTraitDefinition fromMessageNode: expression ].
	^ expression
]

{ #category : #testing }
DASTEvaluator >> primitiveResultIsError: anEPPrimitiveResult [ 
	^ anEPPrimitiveResult hasFailed 
]

{ #category : #'access primitives' }
DASTEvaluator >> primitiveResultValue: anEPPrimitiveResult [ 
	^ anEPPrimitiveResult value
]

{ #category : #decoding }
DASTEvaluator >> valueOf: anEPMirror [
	^ anEPMirror value
]

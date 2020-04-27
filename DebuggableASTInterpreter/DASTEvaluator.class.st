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
	| binding aRGObject |
	 
	binding := self environment bindingOf: aString.
	binding ifNil: [ ^ self error: 'Variable ', aString , ' not defined!' ].
	"Mark the class or global variable as accessed in the ring model"
	aRGObject := self systemDefinition 
		classNamed: aString 
		ifAbsent: [ self systemDefinition globalVariableNamed: aString ].
	aRGObject markAsAccessed.
	^ binding
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

{ #category : #lookup }
DASTEvaluator >> lookupSelector: aByteString startInClass: aClass [
	| method |
	
	method := self pvtLookupSelector: aByteString startInClass: aClass.
	method
		ifNil: [ DASTDoesNotUnderstand signal:
					'The class ' , aClass asString , ' does not understand the message: '
						, aByteString asString ].
	^ method
]

{ #category : #mark }
DASTEvaluator >> markMethodAsAccessed: method [ 
	" Mark the method as accessed in the ring model for deciding wether or not install it later in the kernel"
	| methodClass |
	methodClass := method methodClass == BlockClosure
		ifTrue: [ self systemDefinition classWithRole: 'BlockClosure' ]
		ifFalse: [ method methodClass ].
	methodClass markMethodAsAccessed: method.
	
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

{ #category : #lookup }
DASTEvaluator >> pvtLookupSelector: aByteString startInClass: aClass [
	| class method |
	class := aClass.
	"We perform the lookup"
	method := class lookupSelectorAndMarkTraversedClasses: aByteString.
	method ifNotNil: [ ^ method ].
	"If the method was not found and the receiver is aDASTBlock, 
	we must force the lookup to go in the class Block in the ring model"
	class == DASTBlock
		ifTrue: [ class := self systemDefinition classWithRole: #BlockClosure ].
	method := class lookupSelectorAndMarkTraversedClasses: aByteString.
	"If the method was not found it will be nil"
	^ method
]

{ #category : #accessing }
DASTEvaluator >> systemDefinition [
	^ codeProvider systemDefinition
]

{ #category : #decoding }
DASTEvaluator >> valueOf: anEPMirror [
	^ anEPMirror value
]

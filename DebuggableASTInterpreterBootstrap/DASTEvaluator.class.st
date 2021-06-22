Class {
	#name : #DASTEvaluator,
	#superclass : #EPASTEvaluator,
	#instVars : [
		'interpreter'
	],
	#category : #'DebuggableASTInterpreterBootstrap-Espell'
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
	^ (self objectSpace backend mirrorOnExternalHandle: aDASTBlock) asRemoteBlock
]

{ #category : #accessing }
DASTEvaluator >> classLoader [
	^ self codeProvider classLoader
]

{ #category : #encoding }
DASTEvaluator >> contextFrom: aDASTContext [
	^ (self objectSpace backend mirrorOnExternalHandle: aDASTContext) asRemoteContext
]

{ #category : #interpreting }
DASTEvaluator >> evaluateAST: ast [
	
	^ self evaluateAST: ast withTemps: #() 
]

{ #category : #interpreting }
DASTEvaluator >> evaluateCode: someCode withTemps: aCollectionOfTemps [
	| temps |
	temps := aCollectionOfTemps collect: [ :assoc | assoc key -> (assoc value asRemoteObjectInObjectSpace: self objectSpace) ].
	^ self evaluateAST: (self parse: someCode) withTemps: temps 
]

{ #category : #primitives }
DASTEvaluator >> executePrimitiveMethod: aDASTMethod withReceiver: anEPMirror withArguments: aCollection [ 
	^ anEPMirror executePrimitiveMethod: aDASTMethod withArguments: aCollection asArray
]

{ #category : #'variables-class' }
DASTEvaluator >> findClassVariable: aString inObject: anObject [ 
	| theClass |
	theClass := anObject isRemoteClass
		ifTrue: [ anObject ]
		ifFalse: [ anObject basicClass ].
	
	^ theClass innerBindingOf: aString.
]

{ #category : #'variables-class' }
DASTEvaluator >> findClassVariable: aName inObjectAndItsParents: remoteObject [
	| class superclass |
	class := remoteObject isRemoteClass
		ifTrue: [ remoteObject ]
		ifFalse: [ remoteObject basicClass ].
	
	superclass := class.
	[ superclass isNilObject ] whileFalse: [ 
		| superclassDefinition |
		(superclass innerBindingOf: aName) ifNotNil: [:assoc | ^ assoc].
		superclassDefinition := superclass asRGClass superclass.
		superclass := superclassDefinition 
			ifNil: [ objectSpace nilObject ]
			ifNotNil: [ codeProvider classNamed: superclassDefinition name ].
		 ].
	^ nil
]

{ #category : #'variables-global' }
DASTEvaluator >> findGlobalVariable: aString [
	| binding aRGObject |
	 
	binding := self environment bindingOf: aString.

	binding ifNil: [ | classDefinition |
		"try to load the class from the local system to the metamodel"
		classDefinition:=self systemDefinition hookGlobalNotFound: aString.
		"now we try finding the variable again"
		binding := self environment bindingOf: aString
		 ].
	binding ifNil: [ ^nil ].
	aRGObject := self systemDefinition 
		classNamed: binding name 
		ifAbsent: [ self systemDefinition globalVariableNamed: aString ].
	
	"Mark the class or global variable as accessed in the ring model"	
	aRGObject markAsAccessed.
	^ binding
]

{ #category : #'variables-instance' }
DASTEvaluator >> findInstanceVariable: aName inObject: anObject [

	^ [anObject instanceVariableNamed: aName]
			on: EP2SlotNotFoundException 
			do: [nil].
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
	methodClass := 
		(method methodClass == BlockClosure or: method methodClass == Object)
			ifTrue: [ self systemDefinition classBlockClosure ]
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
	(expression isSequence and: [ self classLoader isClassDefinition: aString ])
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
	method ifNotNil: [
		"we are not marking blockClosure methods in the metamodel, nor adding them :(. 
		Pending!"
		^ method ].
	"If the method was not found and the receiver is aDASTBlock, 
	we must force the lookup to go in the class Block in the ring model"
	class == DASTBlock
		ifTrue: [ class := self systemDefinition classBlockClosure ].
	class == DASTMethodContext
		ifTrue: [ class := self systemDefinition classContext ].
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

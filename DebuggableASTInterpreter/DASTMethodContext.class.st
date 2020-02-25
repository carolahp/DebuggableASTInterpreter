"
I am a context created to evaluate the body of a method
"
Class {
	#name : #DASTMethodContext,
	#superclass : #DASTContext,
	#category : #'DebuggableASTInterpreter-Contexts'
}

{ #category : #'accessing - private' }
DASTMethodContext >> allInstVars [ 
	^ (self evaluator nilObject = receiver) 
		ifTrue: [ #() ] 
		ifFalse: [ receiver allInstVars ] 
]

{ #category : #'accessing - private' }
DASTMethodContext >> allTemps [
	^ self variablesDict associations
]

{ #category : #'API-lookup' }
DASTMethodContext >> findLocalVariable: aName [
	^ variablesDict 
		associationAt: aName 
		ifAbsent: [ nil ].
		
]

{ #category : #highlighting }
DASTMethodContext >> highlightInterval [
	^ self currentNode debugHighlightRange
]

{ #category : #accessing }
DASTMethodContext >> icon [
	^ Smalltalk iconNamed: #smallWarningIcon
]

{ #category : #initialization }
DASTMethodContext >> initializeContext [

	| theMethod theClassMethodDic aClass aSelector result 
	  compiledMethod ast visitor flatNodes | 
	
	self	parent: sender.
	aSelector := messageNode selector.
	
	aClass := self getClassForLookup.
	compiledMethod := self lookupSelector: aSelector startInClass: aClass.
	ast := DASTMethod new initializeWith: compiledMethod ast evaluator: self evaluator. 
	visitor := DASTPostOrderTreeVisitor new.
	ast body acceptVisitor: visitor.
	flatNodes := visitor stack.
	
	self 	methodOrBlock: ast;
			nodes: flatNodes
	
	"the next comment contains the optimization for saving the methods already looked up. 
	It is commented because it produces a loop forever when we interpret the interpreter interpreting a primitive, such as 1+2"
	"
	theClassMethodDic := self evaluator astCache at: aClass name ifAbsentPut: [ 
		IdentityDictionary new 
		].
	 result := theClassMethodDic at: aSelector ifAbsentPut: [ |compiledMethod ast visitor flatNodes |
			compiledMethod := self lookupSelector: aSelector startInClass: aClass.
			ast := DASTMethod new initializeWith: compiledMethod ast. 
			visitor := DASTPostOrderTreeVisitor new.
			ast body acceptVisitor: visitor.
			flatNodes := visitor stack.		
			{ ast .  flatNodes }].
	theMethod := (result at:1) copy.
	nodes := (result at:2) copy.
	currentNode := nodes top.
	self 	methodOrBlock: theMethod;
			nodes: nodes.
	"
	
]

{ #category : #initialization }
DASTMethodContext >> isBlockContext [ 
	^ false
]

{ #category : #testing }
DASTMethodContext >> isEPDASTBlockMirror [
	^ false
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
				ifTrue: [ ^  aStream nextPutAll: 'DAST Context (no closure assigned yet)' ].
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

{ #category : #modifying }
DASTMethodContext >> removePrimitiveFromMethod [
	
	self methodOrBlock evaluatePrimitive: false
]

{ #category : #accessing }
DASTMethodContext >> temps: aCollection [ 
	aCollection do: [ :assoc | self at: assoc key put: assoc value ]
]

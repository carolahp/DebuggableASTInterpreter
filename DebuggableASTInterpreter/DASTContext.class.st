"
I store variables and its values. I also contain a reference to my parent and sender contexts. 
My method find: looks for a variable in myself and up in my parent contexts chain.
"
Class {
	#name : #DASTContext,
	#superclass : #Object,
	#instVars : [
		'variablesDict',
		'receiver',
		'nodes',
		'executedNodes',
		'stack',
		'parent',
		'closure',
		'messageNode',
		'sender',
		'tempVarIndex',
		'tempVarsNamesIndexes',
		'unhandledException',
		'currentNode'
	],
	#classVars : [
		'valueToBlockMessages'
	],
	#category : #'DebuggableASTInterpreter-Contexts'
}

{ #category : #'instance creation' }
DASTContext class >> newWithSender: aDASTContext receiver: aReceiver messageNode: aRBMessageNode [ 
	| context |
	context := ((aReceiver isKindOf: DASTBlock) 
					and: [ " Check if the message is one of the variants of value. This is very ugly and must be changed when implementing environments "
						self valueToBlockMessages keys includes: aRBMessageNode selector ])
		ifTrue: [ DASTBlockContext new ]
		ifFalse: [ DASTMethodContext new ].
	context sender: aDASTContext;
		receiver: aReceiver;
		messageNode: aRBMessageNode.
	^ context initializeContext
]

{ #category : #'instance creation' }
DASTContext class >> valueToBlockMessages [
	^ valueToBlockMessages 
		ifNil: [ valueToBlockMessages := (BlockClosure methodDict select: [ :e | (201 to: 206) includes: e primitive ]) collect: [ :e | e selector ] ]
]

{ #category : #'API-store' }
DASTContext >> at: aByteSymbol put: anObject [
	self setIndexForTempVarNamed: aByteSymbol.
	^self variablesDict at: aByteSymbol put: anObject.
	
	
]

{ #category : #testing }
DASTContext >> canExecute [
	^ self nodes isNotEmpty and: [ self unhandledException isNil ]
]

{ #category : #'closure support' }
DASTContext >> contextTag [
	^ self
]

{ #category : #accessing }
DASTContext >> currentNode [
	^ currentNode
]

{ #category : #accessing }
DASTContext >> currentNode: aRBVariableNode [ 
	currentNode := aRBVariableNode
]

{ #category : #'accessing - private' }
DASTContext >> definesLocalVariableNamed: aName [
	"Return true if the context defines the local variable"
	^ self variablesDict keys includes: aName
]

{ #category : #'private-exceptions' }
DASTContext >> evaluateSignal: exception [
	"The following primitive is just a marker used to find the evaluation context. 
	See MethodContext>>#isHandlerOrSignalingContext. "
	<primitive: 199>
	| value |
	exception privHandlerContext: self contextTag.
	value := self exceptionHandlerBlock cull: exception.	
	"return from self if not otherwise directed in handle block"
	self return: value
]

{ #category : #'accessing - private' }
DASTContext >> exception [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	self flag: 'Access from temps'.
	^self tempAt: 1

]

{ #category : #'accessing - private' }
DASTContext >> exceptionClass [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	self flag: 'Access from temps'.
	^self tempAt: 1

]

{ #category : #'private-exceptions' }
DASTContext >> exceptionHandlerBlock [
	"handlercontext only. access temporaries from BlockClosure>>#on:do:"
	self flag: 'Access from temps'.
	^self tempAt: 2

]

{ #category : #accessing }
DASTContext >> executedNodes [
	^executedNodes ifNil:[executedNodes := DASTStack new]
]

{ #category : #'API-lookup' }
DASTContext >> findClassVariable: aName [
	^ receiver isClass 
		ifTrue: [ receiver bindingOf: aName ]
		ifFalse:[ receiver class bindingOf: aName ]
]

{ #category : #query }
DASTContext >> findContextSuchThat: testBlock [
	"Search self and my sender chain for first one that satisfies testBlock.  Return nil if none satisfy"

	| context |
	context := self.
	[ context isNil ] whileFalse: [
		(testBlock value: context) 
			ifTrue: [ ^ context ].
		context := context sender ].
	^ nil
]

{ #category : #'API-lookup' }
DASTContext >> findInstanceVariable: aName [
	[^ aName -> (self receiver instVarNamed: aName) ]
		on: InstanceVariableNotFound do: [ ^nil ] 
]

{ #category : #'API-lookup' }
DASTContext >> findLocalVariable: aName [

	^ variablesDict 
		associationAt: aName 
		ifAbsent: [ nil ]
]

{ #category : #'private-exceptions' }
DASTContext >> findNextHandlerContext [
	"Return the next handler marked context, returning nil if there is none.  Search starts with self and proceeds up to nil."

	| context |
	context := self findNextHandlerOrSignalingContext.
	context isNil
		ifTrue: [ ^ nil ].
	context isHandlerContext
		ifTrue: [ ^ context ].	"If it isn't a handler context, it must be a signaling context.
	When we reach a signaling context we must skip over any handlers
	that might be on the stack between the signaling context and the handler
	context for that signal."
	^ context exception privHandlerContext nextHandlerContext
]

{ #category : #'private-exceptions' }
DASTContext >> findNextHandlerOrSignalingContext [
	"Return the next handler/signaling marked context, answering nil if there is none. 
	Search starts with self and proceeds up to nil."

	"<primitive: 197>"
	| context |
	context := self.
	[ 
	context isHandlerOrSignalingContext
		ifTrue: [ ^ context ].
	(context := context sender) == nil ] whileFalse.
	^ nil
]

{ #category : #'private-exceptions' }
DASTContext >> findNextUnwindContextUpTo: aContext [
	"Return the next unwind marked above the receiver, returning nil if there is none.  Search proceeds up to but not including aContext."

	| context |
	<primitive: 195>
	context := self.
	[
		(context := context sender) == nil
		or: [ context == aContext ]
	] whileFalse: [
		context isUnwindContext
			ifTrue: [ ^context ]].
	^nil
]

{ #category : #'API-lookup' }
DASTContext >> findVariable: aByteSymbol [
	|association|
	"Return the value of a variable. If this context redefines a variable defined by its parent context, this method will return the variable value for this context"
	
	"local variables"
	association := self findLocalVariable: aByteSymbol.
	association ifNotNil: [ ^ association value ].
	
	"instance variables"
	association := self findInstanceVariable: aByteSymbol.
	association ifNotNil: [ ^ association value ].
	
	"class variables"
	association := self findClassVariable: aByteSymbol.
	association ifNotNil: [ ^ association value ].
	
	^ parent 
			ifNil: [ self error: 'Variable ', aByteSymbol , ' not defined!'  ] 
			ifNotNil: [ :pc | pc findVariable: aByteSymbol ]
]

{ #category : #'accessing - private' }
DASTContext >> getClassForLookup [

	 ^ messageNode isSuperSend 
			ifTrue: [messageNode methodNode methodClass superclass] 
			ifFalse: [self receiver class]
]

{ #category : #'gt-extension' }
DASTContext >> gtInspectorSendersIn: composite [
	<gtInspectorPresentationOrder: 0>
	^composite tree
		rootsExpanded;
		title: 'Senders';
		display: [ {self} ];
		children: [ :each | each senders ]
]

{ #category : #'gt-extension' }
DASTContext >> gtInspectorSourceIn: composite [
	<gtInspectorPresentationOrder: 0> 
	| nodeHighlight |
	nodeHighlight := self currentNode ifNil: [ self nodes first ] ifNotNil: [ self currentNode ].
	(self methodOrBlock 
		gtInspectorIn: composite 
		highlightInterval: (Interval from: nodeHighlight debugHighlightStart to: nodeHighlight debugHighlightStop))
]

{ #category : #accessing }
DASTContext >> handleSignal: exception [
	"Sent to handler (on:do:) contexts only.  If my exception class (first arg) handles exception then execute my handle block (second arg), otherwise forward this message to the next handler context.  If none left, execute exception's defaultAction (see nil>>handleSignal:)."
	(self exceptionClass handles: exception)
		ifFalse: [ ^ self nextHandlerContext handleSignal: exception ].
	^ self evaluateSignal: exception
]

{ #category : #'private-exceptions' }
DASTContext >> hasSender: context [ 
	"Answer whether the receiver is strictly above context on the stack."

	| senderContext |
	self == context 
		ifTrue: [^false].
	senderContext := sender.
	[senderContext == nil]
		whileFalse: [
			senderContext == context
				ifTrue: [^true].
			senderContext := senderContext sender].
	^false
]

{ #category : #initialization }
DASTContext >> initialize [
	super initialize.
	stack := DASTStack new.
	variablesDict := Dictionary new.
	tempVarsNamesIndexes := Dictionary new.
	tempVarIndex := 0
]

{ #category : #testing }
DASTContext >> isBlockContext [

	self subclassResponsibility 
]

{ #category : #testing }
DASTContext >> isEmpty [
	
	^ variablesDict isEmpty.
]

{ #category : #'private-exceptions' }
DASTContext >> isHandlerContext [
	"is this context for #on:do:?"
	^self isHandlerOrSignalingContext and: [ self selector == #on:do: ]
]

{ #category : #'private-exceptions' }
DASTContext >> isHandlerOrSignalingContext [
	"Both BlockClosure>>on:do: (handler) and Context>>evaluateSignal: (signaling) 
	are marked with primitive 199."
	^((self isBlockContext) or: [ self isRoot ]) not and:  [closure primitive = 199]
]

{ #category : #testing }
DASTContext >> isNoMethod [
	^ false
]

{ #category : #testing }
DASTContext >> isRoot [ 
	^false
]

{ #category : #'private-exceptions' }
DASTContext >> isUnwindContext [
	^ self subclassResponsibility 
]

{ #category : #'accessing - private' }
DASTContext >> lookupContextDefiningLocalVariable: aByteSymbol [
	
	(self definesLocalVariableNamed: aByteSymbol) ifTrue: [ ^ self ].
	
	^ self isBlockContext
		ifTrue: [ closure outerContext lookupContextDefiningLocalVariable: aByteSymbol ]
		ifFalse: [ nil ]
]

{ #category : #'API-lookup' }
DASTContext >> lookupSelector: aByteString startInClass: aClass [ 
	| lclass |
	lclass := 
		(aClass == UnhandledError) 
			ifTrue: [ DASTErrorNonInteractive ]
			ifFalse: [ aClass ].
	^( lclass lookupSelector: aByteString)
		ifNil: [ "ToDo: implement does not understand" 
					self error: 'The class ',lclass asString,' does not understand the message: ', aByteString asString ].
	
]

{ #category : #accessing }
DASTContext >> messageNode: aRBMessageNode [ 
	messageNode := aRBMessageNode
]

{ #category : #accessing }
DASTContext >> method [
	^ self methodOrBlock 
]

{ #category : #accessing }
DASTContext >> methodOrBlock [
	^ closure
]

{ #category : #accessing }
DASTContext >> methodOrBlock: aDASTClosure [

	closure := aDASTClosure
]

{ #category : #initialization }
DASTContext >> namedTempAt: anIndex [
	^ self variablesDict at: (self tempNames at: anIndex) 
]

{ #category : #'private-exceptions' }
DASTContext >> nextHandlerContext [

	^ self sender findNextHandlerContext
]

{ #category : #accessing }
DASTContext >> nodes [ 
	^nodes ifNil: [ nodes := DASTStack new ]
]

{ #category : #accessing }
DASTContext >> nodes: aStack [ 
	nodes := aStack
]

{ #category : #accessing }
DASTContext >> parent [
	" This context is used for performing the lookup operations "
	^ parent
]

{ #category : #accessing }
DASTContext >> parent: aDASTContext [
	" This context is used for performing the lookup operations "
	parent := aDASTContext
]

{ #category : #accessing }
DASTContext >> printOn: aStream [
	"aStream
		cr;
		nextPutAll: (receiver ifNotNil: [ receiver asString ] ifNil: [ 'nil' ]);
		nextPutAll: ' <- ';
		nextPutAll: (closure ifNotNil: [ closure selector asString ] ifNil: ['nil'])."
		
	aStream
		nextPutAll: 'DAST Context standard'
		
]

{ #category : #accessing }
DASTContext >> receiver [
	^ receiver
]

{ #category : #accessing }
DASTContext >> receiver: anObject [
	receiver := anObject
]

{ #category : #modifying }
DASTContext >> removePrimitiveFromMethod [
	
	closure nodeAST removePragma: (closure nodeAST pragmas select: [ :p | p isPrimitive ]) first
]

{ #category : #'private-exceptions' }
DASTContext >> resume: value [
	self resume: value through: (thisContext findNextUnwindContextUpTo: self)
]

{ #category : #'private-exceptions' }
DASTContext >> resume: value through: firstUnwindContext [
	"Unwind thisContext to self and resume with value as result of last send.
	 Execute any unwind blocks while unwinding.
	 ASSUMES self is a sender of thisContext."

	| context unwindBlock |
"	self isDead 
		ifTrue: [ self cannotReturn: value to: self ]."
	context := firstUnwindContext.
	[ context isNil ] whileFalse: [	
		context unwindComplete ifNil:[
			"context unwindComplete: true."
			"unwindBlock := context unwindBlock."
			thisContext terminateTo: context.
			"unwindBlock value"].
		context := context findNextUnwindContextUpTo: self].
	thisContext terminateTo: self.
	^value

]

{ #category : #'private-exceptions' }
DASTContext >> return: value [
	sender resume: value
]

{ #category : #accessing }
DASTContext >> returnContext [ 
	^self isBlockContext 
		ifTrue: [ ^ parent returnContext ]
		ifFalse: [ ^ sender  ]
]

{ #category : #accessing }
DASTContext >> selector [

	^closure selector ifNil: [closure defaultSelector].
]

{ #category : #accessing }
DASTContext >> sender [
	^ sender 
]

{ #category : #accessing }
DASTContext >> sender: aDASTContext [
	sender := aDASTContext
]

{ #category : #accessing }
DASTContext >> senders [
	| context result |
	context := self sender.
	result := OrderedCollection new.
	[ context isNil ] whileFalse: [ 
		result add: context.
		context := context sender
		 ].
	^ result
]

{ #category : #'API-store' }
DASTContext >> setIndexForTempVarNamed: tempVarName [
	tempVarsNamesIndexes
		at: tempVarName
		ifAbsentPut: [ tempVarIndex := tempVarIndex + 1 ]
]

{ #category : #accessing }
DASTContext >> setTemporalVariablesNamed: names values: values [
	values doWithIndex: 
		  [ :val :index | 
				self 
					at: (names at: index)
					 put: val ].
]

{ #category : #'accessing - private' }
DASTContext >> stack [
	^ stack
]

{ #category : #'accessing - private' }
DASTContext >> stack: anObject [
	stack := anObject
]

{ #category : #'accessing - private' }
DASTContext >> tempAt: anIndex [
	^ self variablesDict at: (self variablesDict keys at: anIndex)
]

{ #category : #'accessing - private' }
DASTContext >> tempNames [
	^ self variablesDict keys
]

{ #category : #'private-exceptions' }
DASTContext >> terminate [
	"Make myself unresumable."
	nodes removeAll.
	sender := nil.

]

{ #category : #'private-exceptions' }
DASTContext >> terminateTo: previousContext [
	"Terminate all the Contexts between me and previousContext, if previousContext is on my Context stack. Make previousContext my sender."

	| currentContext sendingContext |
	<primitive: 196>
	(self hasSender: previousContext) ifTrue: [
		currentContext := sender.
		[currentContext == previousContext] whileFalse: [
			sendingContext := currentContext sender.
			currentContext terminate.
			currentContext := sendingContext ]].
	sender := previousContext
]

{ #category : #accessing }
DASTContext >> unhandledException [
	^ unhandledException
]

{ #category : #accessing }
DASTContext >> unhandledException: anObject [
	^ unhandledException := anObject
]

{ #category : #accessing }
DASTContext >> unwindComplete [
	"unwindContext only. access temporaries from BlockClosure>>#ensure: and BlockClosure>>#ifCurtailed:"
	self flag: 'Access temps'.
	^self tempAt: 2
]

{ #category : #'accessing - private' }
DASTContext >> variablesDict [
	^ variablesDict
]

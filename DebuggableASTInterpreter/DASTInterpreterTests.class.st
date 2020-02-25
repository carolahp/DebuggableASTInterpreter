Class {
	#name : #DASTInterpreterTests,
	#superclass : #DASTAbstractInterpreterTests,
	#category : #'DebuggableASTInterpreter-Tests'
}

{ #category : #tests }
DASTInterpreterTests >> testAddTwoNumbers [

	self assert: (self evaluateProgram: '^1+2' ) 
		  equals: 3
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testArgumentVarUsedToSetLocalVar [
	
	self assert: (self evaluateProgram:  'DASTInterpreterClassForTests new assignateArgumentToLocalVar: 4') 
		  equals: 4
		
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testArgumentVarUsedToSetLocalVarInsideBlock [
	
	self assert: (self evaluateProgram:  'DASTInterpreterClassForTests new assignateArgumentToLocalVarInsideBlock: 4') 
		  equals: 4
		
]

{ #category : #tests }
DASTInterpreterTests >> testArray [

	self assert: (self evaluateProgram: '{1 . 2 .  3}') 
		  equals: {1 . 2 . 3}
]

{ #category : #tests }
DASTInterpreterTests >> testArrayWithBlocksThatReturnEvaluated [

	self assert: (self evaluateProgram: '{[^1] value . [^2] value . [^3] value}') 
		  equals: 1
]

{ #category : #tests }
DASTInterpreterTests >> testArrayWithEvaluatedContents [

	self assert: (self evaluateProgram: '{1 + 6 . 2 .  3}') 
		  equals: {1 + 6 . 2 . 3}
]

{ #category : #tests }
DASTInterpreterTests >> testArrayWithEvaluatedContentsFromMessage [

	self assert: (self evaluateProgram: '{-6 abs . 2 .  3}') 
		  equals: {-6 abs . 2 . 3}
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testBlockAssignedToVariableAndEvaluated [

	self assert: (self evaluateProgram: '|b| b := [^ 3]. b value' ) 
		  equals: 3
	
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testBlockEvaluated [

	self assert: (self evaluateProgram: '[^ 3] value' ) 
		  equals: 3
	
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testBlockLocalVariableAccessedFromAnidatedBlock [

	self assert: (self evaluateProgram: '[:x | [ x ] value ] value: true' ) 
		  equals: true
	
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testBlockWithParameter [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new getBlockWithParameter' ) 
		  equals: 123
	
]

{ #category : #'tests-variables-class-instance' }
DASTInterpreterTests >> testClassInstanceVarScopeIsRespectedWhenInherited [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests5 initialize .  DASTInterpreterClassForTests4 initialize . DASTInterpreterClassForTests5 new . ^ {DASTInterpreterClassForTests5 count . DASTInterpreterClassForTests4 count }' ) 
		  equals: { 1 . 0} 
		

]

{ #category : #'tests-super' }
DASTInterpreterTests >> testCustomInitializationUsingSuper [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests5 new class' ) 
		  equals: DASTInterpreterClassForTests5
		

]

{ #category : #'tests-program counter' }
DASTInterpreterTests >> testDecreaseProgramCounter [
	interpreter decreasePC.
	self assert: interpreter programCounter equals: -1
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testEmptyBlock [

	self assert: (self evaluateProgram: '[ ] value' ) 
		  equals: nil
	
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testEmptyMethod [
	self assert: ((self evaluateProgram: 'DASTInterpreterClassForTests5 new m5') class) 
		  equals: DASTInterpreterClassForTests5
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testEmptyMethodIndirectCall [
	self assert: ((self evaluateProgram: 'DASTInterpreterClassForTests5 new m6') class) 
		  equals: DASTInterpreterClassForTests5
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testEmptyMethodValueLink [
	self assert: ((self evaluateProgram: 'ValueLink new') class) 
		  equals: ValueLink
]

{ #category : #'tests-exceptions-ensure' }
DASTInterpreterTests >> testEnsure [
	self assert: (self evaluateProgram: '[1] ensure: [2]')
		  equals: 1 
]

{ #category : #tests }
DASTInterpreterTests >> testEvaluateArgumentOrder [ 
	
	self assert: (self evaluateProgram: 'Array braceWith: 1 with: 2' ) 
		  equals: #(1 2)
]

{ #category : #tests }
DASTInterpreterTests >> testEvaluateConstant [

	self assert: (self evaluateProgram: '1' ) 
		  equals: 1
]

{ #category : #tests }
DASTInterpreterTests >> testEvaluateFullExpression [
	
	self assert: (self evaluateProgram: '1 - 3 abs' ) 
		  equals: -2
]

{ #category : #tests }
DASTInterpreterTests >> testEvaluateMessageWithoutArguments [

	self assert: (self evaluateProgram: '-1 abs' ) 
		  equals: 1
]

{ #category : #tests }
DASTInterpreterTests >> testEvaluateSubstraction [
	
	self assert: (self evaluateProgram: '1 - 3' ) 
		  equals: -2
]

{ #category : #'tests-exceptions' }
DASTInterpreterTests >> testExceptionSignal [
	self evaluateProgram: 'ZeroDivide signal'.
	self assert: interpreter stackTop class
		  equals: ZeroDivide 
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testExceptionSignalInDoBlock [
	self evaluateProgram: '[ ZeroDivide signal ] on: ZeroDivide do: [ Error signal ]'.
	self assert: interpreter stackTop class
		  equals: Error 
]

{ #category : #'tests-exceptions' }
DASTInterpreterTests >> testExceptionSignalInSequence [
	self deny: (self evaluateProgram: 'ZeroDivide signal. 2') 
		  equals: 2
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testExecutedNodesAfterExecution [
	| nodesStackBackup contextBackup |
	self initializeProgram: 'Point x: 1 y: 2'.
	contextBackup := interpreter currentContext.
	nodesStackBackup := contextBackup nodes asArray.
	interpreter evaluate.
	self flag: 'That cannot work, as the execution for the #x:y: method "inserts" the body of the method node in the nodes stack'.
	self
		assert: interpreter currentContext executedNodes asArray reversed
		equals: nodesStackBackup
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testExecutedNodesAfterStepInto [
	| nodesStackBackup contextBackup |
	self initializeProgram: '^Point x: 1 y: 2'.
	contextBackup := interpreter currentContext.
	nodesStackBackup := contextBackup nodes copy.
	interpreter stepInto.
	self
		assert: interpreter currentContext executedNodes
		equals: (DASTStack new push: (RBGlobalNode named: #Point); yourself)
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testExecutedNodesAfterStepOver [
	| expectedStack |
	self initializeProgram: '^Point x: 1 y: 2'.
	expectedStack := DASTStack new.
	expectedStack push: (RBGlobalNode named: #Point).
	expectedStack push: (RBLiteralValueNode value: 1).
	expectedStack push: (RBLiteralValueNode value: 2).
	interpreter stepOver.
	interpreter stepOver.
	interpreter stepOver.
	self
		assert: interpreter currentContext executedNodes
		equals: expectedStack
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testExecutedNodesAtExecutionStart [
	self initializeProgram: 'Point x: 1 y: 2'.
	self assert: interpreter currentContext executedNodes isEmpty
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testFalse [
	self assert: (self evaluateProgram: 'false')
		  equals: false
]

{ #category : #'tests-variables-class' }
DASTInterpreterTests >> testGetClassVariableFromMethodInInstanceSide [
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests3 new getClassVariable' ) 
		  equals: 42
		

]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testIfTrue [

	self assert: (self evaluateProgram: 'true ifTrue: [3]' ) 
		  equals: 3
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testIfTrueThatWritesLocalVar [

	self assert: (self evaluateProgram: '|x| x := 1 . true ifTrue: [x:=2] . x' ) 
		  equals: 2
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testIfTrueWithEvaluationAsReceiver [

	self assert: (self evaluateProgram: '1<2 ifTrue: [3]' ) 
		  equals: 3
]

{ #category : #'tests-program counter' }
DASTInterpreterTests >> testIncreaseProgramCounter [
	interpreter increasePC.
	self assert: interpreter programCounter equals: 1
]

{ #category : #'tests-program counter' }
DASTInterpreterTests >> testIncreaseProgramCounterWhenSteppingIntoAMessage [
	self initializeProgram: '5 squared'.
	interpreter stepOver.
	interpreter stepInto.
	self assert: interpreter programCounter equals: 2
]

{ #category : #'tests-program counter' }
DASTInterpreterTests >> testIncreaseProgramCounterWhenSteppingIntoANode [
	self initializeProgram: '4 + 2'.
	interpreter stepInto.
	self assert: interpreter programCounter equals: 1
]

{ #category : #'tests-program counter' }
DASTInterpreterTests >> testIncreaseProgramCounterWhenSteppingOverANode [
	self initializeProgram:  '1 asNumber'.
	interpreter stepOver.
	interpreter stepOver.
	self assert: interpreter programCounter equals: 4
]

{ #category : #'tests-program counter' }
DASTInterpreterTests >> testInitialProgramCounter [
	self assert: interpreter programCounter equals: 0
]

{ #category : #'tests-variables-instance' }
DASTInterpreterTests >> testInitializeWithInstanceVariables [
	
	self assert: (self evaluateProgram: '| obj | 
													obj := DASTInterpreterClassForTests6 new initializeIV1: 1 IV2: 2 . 
													obj iv1' ) 
		  equals: 1.
	self assert: (self evaluateProgram: '| obj | 
													obj := DASTInterpreterClassForTests6 new initializeIV1: 1 IV2: 2 . 
													obj iv2' ) 
		  equals: 2
]

{ #category : #'tests-variables-instance' }
DASTInterpreterTests >> testInstanceVarIsCapturedInBlockCreation [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests3 new evaluateBlock' ) 
		  equals: 123
		

]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testInstantiateObject [

	self assert: (self evaluateProgram: '^Point basicNew') 
		  equals: (Point basicNew)
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testInstantiateObjectAndSetInstanceVariables [

	self assert: (self evaluateProgram: 'Point x: 1 y: 2') 
		  equals: (Point x: 1 y: 2)
	
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testInstantiateObjectAndSetInstanceVariablesAndGetInstanceVariables [

	self assert: (self evaluateProgram: '|p| p:= Point x: 1 y: 2 .^ p x') 
		  equals: 1

]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretBlockCreatedInDifferentContext [

	self assert: (self evaluateProgram: '^DASTInterpreterClassForTests new getBlockThatEvaluatesConstant42 value')
		  equals:42.

]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretBlockDeclarationWithOuterContext [

	| anInterpreter value |
	anInterpreter := DASTInterpreter new.
	anInterpreter initializeWithProgram: (RBParser parseExpression: '|x| x := 3 . ^ [ 1 ]').
	anInterpreter evaluate.
	value := anInterpreter stackTop.
	self assert: value asText equals: [ 1 ] asText.
	self assert: (value outerContext findVariable: #x) equals: 3.
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretBlockDeclarationWithoutOuterContext [

	| anInterpreter value |
	anInterpreter := DASTInterpreter new.
	anInterpreter initializeWithProgram: (RBParser parseExpression: '[ 1 ]').
	anInterpreter evaluate.
	value := anInterpreter stackTop.
	self assert: value asText equals: [ 1 ] asText.
	self assert: value outerContext isEmpty.
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretBlockEvaluationWithOneArgument [

	self assert: (self evaluateProgram: '[ :x | x ] value: 2')
		  equals:2

]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretBlockEvaluationWithTwoArguments [

	self assert: (self evaluateProgram: '[ :x :y | x + y ] value: 1 value: 2')
		  equals:3.

]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretBlockEvaluationWithoutArgumentsAndWithoutOuterContext [

	self assert: (self evaluateProgram: '^ [ 1 ] value')
		  equals:1
]

{ #category : #'tests-reflective-interpreter' }
DASTInterpreterTests >> testInterpretItselfAddition [

	self assert: (self evaluateProgram: 'DASTInterpreter new initializeWithProgram: (RBParser parseExpression: ''1 + 5''); evaluate')
		  equals: 6
]

{ #category : #'tests-reflective-interpreter' }
DASTInterpreterTests >> testInterpretItselfInteger [

	self assert: (self evaluateProgram: 'DASTInterpreter new initializeWithProgram: (RBParser parseExpression: ''1''); evaluate')
		  equals: 1
]

{ #category : #'tests-reflective-interpreter' }
DASTInterpreterTests >> testInterpretItselfLessThan [

	self assert: (self evaluateProgram: 'DASTInterpreter new initializeWithProgram: (RBParser parseExpression: ''1<2''); evaluate')
		  equals: true
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testInterpretSendingMessageDifferentFromValueToBlock [
	
	self assert: (self evaluateProgram: '^ [ :x :y :z | 1 ] argumentCount')
		  equals: 3
	
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testLessThan [

	self assert: (self evaluateProgram: '^ 1<2')
		  equals: true
]

{ #category : #tests }
DASTInterpreterTests >> testLiteralArray [

	self assert: (self evaluateProgram: '#(1 2 3)') 
		  equals: #(1 2 3)
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarAccessedForUpdatingItsOwnValue [

	self assert: (self evaluateProgram: '|x| x := 1 . x := x + 2 .  x' ) 
		  equals: 3
		

]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarAsArgumentInMessage [

	self assert: (self evaluateProgram: '|x| x := 1 . ^ 2 + x' ) 
		  equals: 3
		
	
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarAsReceiverInMessage [

	self assert: (self evaluateProgram: '|x| x := 1 . ^ x + 2' ) 
		  equals: 3
		
	
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarAssignationAndEvaluation [
	
	self assert: (self evaluateProgram: '|x| x := 1. ^ x' ) 
		  equals: 1
		
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarLastAssignationPrevails [

	self assert: (self evaluateProgram: '|x| x := 1 . x := 2 . ^ x ') 
		  equals: 2
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenAccessedFromABlockCreatedInADifferentContext [
	
	self assert: (self evaluateProgram: '^ DASTInterpreterClassForTests new getBlockThatAccessesVariableTSetAs42 value' ) 
		  equals: 42
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenAccessedFromABlockCreatedInADifferentContextAndItsModifiedInCurrentContext [
	
	self assert: (self evaluateProgram: '|t| t:= nil . ^ DASTInterpreterClassForTests new getBlockThatAccessesVariableTSetAs42 value' ) 
		  equals: 42
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenAccessedFromBlock [

	self assert: (self evaluateProgram:  '|x b| x:=1 . b := [^ x] . x:=2 . ^b value' ) 
		  equals: 2
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenAccessedFromBlockAnidated [

	self assert: (self evaluateProgram:  '|x b| x:=1 . b := [[^ x]] . x:=2 . ^b value value' ) 
		  equals: 2
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenAccessedFromSenderContext [

	self should: [ self evaluateProgram:  'DASTInterpreterClassForTests4 new methodWithLocalVarZSetAs5AndThatReturns43. x' ]
		  raise: Error
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenAsignedInOuterContextOfBlockAndUpdatedFromBlock [
	
	self assert: (self evaluateProgram: '^ DASTInterpreterClassForTests new getBlockThatAccessesVariableTSetAs42 value' ) 
		  equals: 42
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenDefinedInBlockSenderAndNotInBlockHome [

	self should: [self evaluateProgram:  '(1 to: 3) collect: [ :i | index ]'] 
		  raise: Exception
	
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenModifiedFromBlock [

	self assert: (self evaluateProgram:  '|x| [ x:=1 ] value  . ^ x ') 
		  equals: 1
	
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenModifiedFromBlockAnidated [

	self assert: (self evaluateProgram:  '|x| [[ x:=1 ]] value value . ^ x ') 
		  equals: 1
	
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testLocalVarScopeWhenUpdatedFromABlockAndEvaluatedInDifferentContext [
	
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new setVariableAndDefineBlock3' ) 
		  equals:  { 33 . 33 . 66 . 66 }
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testLookupGlobalVariable [

	self assert: (self evaluateProgram: 'Point') 
		  equals: Point
]

{ #category : #'tests-cascade' }
DASTInterpreterTests >> testMessageCascade [

	self assert: (self evaluateProgram: '2 raisedTo: 3; raisedTo: 4' ) 
		  equals: 16
]

{ #category : #'tests-cascade' }
DASTInterpreterTests >> testMessageCascadeWithOtherStatement [

	self assert: (self evaluateProgram: '1 raisedTo: 2; raisedTo: 3. true' ) 
		  equals: true
]

{ #category : #'tests-cascade' }
DASTInterpreterTests >> testMessageCascadeWithYourself [

	self assert: (self evaluateProgram: '2 raisedTo: 3; raisedTo: 4; yourself' ) 
		  equals: 2
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testMethodMethodArgumentsAreIndependentFromOtherMethodsArguments [
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new testArg: ''foo'' ')
		  equals: 'foo'
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testMethodReturnsSelfWhenItDoesntContainExplicitReturn [
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new methodEmpty') class = DASTInterpreterClassForTests 
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testMethodReturnsVariableDeclaredInItsBody [
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new getVariableDeclaredInMethod') 
		  equals: 0  
]

{ #category : #'tests-methods' }
DASTInterpreterTests >> testMethodReturnsVariableDeclaredInItsBodyAndReasignedInArray [
	self assert: (self evaluateProgram: '|res| res:= DASTInterpreterClassForTests new getTwoBlocksArray. { res second value . res first value . res second value }') 
		  equals: { 0 . 2 . 2 } 
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testMoreThan [

	self assert: (self evaluateProgram: '1>2')
		  equals: false
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testNonLocalReturn [

	self assert: (self evaluateProgram: '(DASTInterpreterClassForTests new getBlockThatReturns32) value' ) 
		  equals: false
	
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoChainExceptiongCatch [
	
	self assert: (self evaluateProgram: '[ 1/0 ] on: SyntaxErrorNotification, ZeroDivide do: [ 1 ]') 
		  equals: 1	
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoExceptionCatch [
	self assert: (self evaluateProgram: '[ 1/0 ] on: ZeroDivide do: [ true ]') 
		  equals: true
	
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoFromBlocExceptiongCatch [
	self assert: (self evaluateProgram: '[ [ZeroDivide signal] on: Exception do: [ :e | e signal ] ] on: Exception do: [ :e | e ]') class
		  equals: ZeroDivide 
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoFromMethodExceptiongCatch [
	self assert: (self evaluateProgram: '[ [ZeroDivide signal] on: Exception do: [ :e | e signal ] ] on: Exception do: [ :e | e ]') class
		  equals: ZeroDivide 
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoGeneralExceptiongCatch [
	self assert: (self evaluateProgram: '[ 1/0 ] on: Exception do: [ 1 ]') 
		  equals: 1	
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoInSequenceExceptionCatch [
	self assert: (self evaluateProgram: '[ 1/0. 2 ] on: ZeroDivide do: [ true ]. 3') 
		  equals: 3
	
]

{ #category : #'tests-exceptions-ondo' }
DASTInterpreterTests >> testOnDoSequenceInBlockExceptionCatch [
	self assert: (self evaluateProgram: '[ 1/0. 2 ] on: ZeroDivide do: [ true ]') 
		  equals: true
	
]

{ #category : #tests }
DASTInterpreterTests >> testParenthesisForOperationAndUnaryMessage [

	self assert: (self evaluateProgram: '(1 -  3) abs')
	   equals: 2.
]

{ #category : #tests }
DASTInterpreterTests >> testPrecedenceForOperationAndMessageWithArgument [
	
	self assert: (self evaluateProgram: '^ #abc at: 3 - 1')
	   equals: $b
]

{ #category : #tests }
DASTInterpreterTests >> testPrecedenceForOperationAndUnaryMessage [
	
	self assert: (self evaluateProgram: '^ 1 - 3 abs')
	   equals: -2
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testPrimitiveAdd [

	self assert: (self evaluateProgram: '^ 1+2')
		  equals: 3
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testPrimitiveCopy [

	self assert: (self evaluateProgram: '(Point x:1 y:2) copy')
		  equals: 1@2 
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testPrimitiveSubstract [

	self assert: (self evaluateProgram: '^ 1-2')
		  equals: -1
]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testPrimitiveThatFails [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new methodPrimitive9999ThatDoesntExist')
		  equals: true 
]

{ #category : #'tests-return' }
DASTInterpreterTests >> testReturnExplicit [
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new testExplicitReturn')
		  equals: 1 
]

{ #category : #'tests-return' }
DASTInterpreterTests >> testReturnMethodFromBlock [
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests new jumpingOut')
		  equals: 3
]

{ #category : #'tests-self' }
DASTInterpreterTests >> testSelf [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests yourself')
		  equals: DASTInterpreterClassForTests 
]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testSendMessageToBlock [

	self assert: (self evaluateProgram: '[:a :b :c | true ] argumentNames' ) 
		  equals: #(a b c)
	
]

{ #category : #'tests-variables-class' }
DASTInterpreterTests >> testSetAndGetClassVariableFromMethodInInstanceSide [
	"ToDo: reimplement when the environment contains representation of objects"
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests3 new setClassVariable. DASTInterpreterClassForTests3 new getClassVariable' ) 
		  equals: 42
		

]

{ #category : #'tests-variables-class' }
DASTInterpreterTests >> testSetAndGetInheritedClassVariableFromMethodInInstanceSide [
	DASTInterpreterClassForTests4 new setClassVar5: nil.
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests4 new getClassVar5' ) 
		  equals: 5
		

]

{ #category : #'tests-variables-class' }
DASTInterpreterTests >> testSetInheritedClassVariableFromMethodInInstanceSide [
	DASTInterpreterClassForTests4 new setClassVar5: nil.
	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests4 new setClassVar5: 5' ) 
		  equals: 5
		

]

{ #category : #'tests-super' }
DASTInterpreterTests >> testSuperInsideBlock [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests4 new m3' ) 
		  equals: 4
		

]

{ #category : #'tests-super' }
DASTInterpreterTests >> testSuperTheReceiverRemains [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests5 new m1' ) 
		  equals: 3
		

]

{ #category : #'tests-super' }
DASTInterpreterTests >> testSuperTheReceiverRemains1 [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests4 new m1' ) 
		  equals: 42
		

]

{ #category : #'tests-blocks' }
DASTInterpreterTests >> testToDo [

	self assert: (self evaluateProgram: '|x| 
													x := 0.
													1 to: 10 do: [:each | x := x + each].
													x' ) 
		  equals: 55
]

{ #category : #'tests-transcript' }
DASTInterpreterTests >> testTranscript [
	self skip.
	self assert: (self evaluateProgram: 'Transcript show: #a' ) 
		  equals: Transcript
		

]

{ #category : #'tests-primitives' }
DASTInterpreterTests >> testTrue [

	self assert: (self evaluateProgram: '^ true')
		  equals: true
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testVarsLocalBlockAssignsHomeContextLocalVariable [
	
	self assert: (self evaluateProgram:  '|b x| b := [ x:=1 ] . b value . ^ x') 
		  equals: 1
		
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testVarsLocalBlockDeclaredOutsideBlockAndModifiedInAnidatedBlock [

	self assert: (self evaluateProgram:  '|x| [ [ x:=1 ] value  ] value . ^ x') 
		  equals: 1
	
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testVarsLocalEvaluateBlockInDifferentContext [
	
	self assert: (self evaluateProgram:  'DASTInterpreterClassForTests new evaluateBlock: [^33]') 
		  equals: 33
		
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testVarsLocalScopeLookupIsDoneInExceutionTime [
	
	self assert: (self evaluateProgram:  '|block t| t := 42 . block := [ t ] .	t := 69 . ^ DASTInterpreterClassForTests new evaluateBlock: block') 
		  equals: 69
		
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testVarsLocalVariableModifiedInsideWhileTrue [
	
	self assert: (self evaluateProgram:  '| nextValue |
	nextValue := 1.
	[ nextValue <= 10 ]
		whileTrue: [ nextValue := nextValue + 1 ].
	nextValue') 
		  equals: 11
		
]

{ #category : #'tests-variables-local' }
DASTInterpreterTests >> testVarsLocalVariableModifiedInsideWhileTrueAndValueBlock [
	
	self assert: (self evaluateProgram:  '| nextValue block |
	nextValue := 1.
	block := [ :x | x ].
	[ nextValue <= 10 ]
		whileTrue: [ block value: nextValue . nextValue := nextValue + 1 ].
	nextValue') 
		  equals: 11
		
]

{ #category : #'tests-self' }
DASTInterpreterTests >> testYourSelfTwice [

	self assert: (self evaluateProgram: 'DASTInterpreterClassForTests yourself yourself')
		  equals: DASTInterpreterClassForTests 
]

{ #category : #'tests-contexts' }
DASTInterpreterTests >> testYourself [

	self assert: (self evaluateProgram: '2+3;yourself' ) 
		  equals: 2
]

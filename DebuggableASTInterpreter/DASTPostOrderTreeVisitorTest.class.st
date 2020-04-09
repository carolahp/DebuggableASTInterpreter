Class {
	#name : #DASTPostOrderTreeVisitorTest,
	#superclass : #DASTAbstractInterpreterTests,
	#category : 'DebuggableASTInterpreter-Tests'
}

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> assertVisitorStack: visitor equalsStack: expectedStack [
	self
		assertCollection: visitor stack asArray
		equals: (expectedStack collect: [ :e | RBParser parseExpression: e ])
]

{ #category : #asserting }
DASTPostOrderTreeVisitorTest >> assertVisitorTop: visitor equals: aString [ 

	self assert: visitor top equals: (RBParser parseExpression: aString).

]

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> testCascade [

	| ast visitor |
	ast := RBParser parseExpression: ' ^ DASTInterpreterClassForTests5 new m3; m4'.
	visitor := DASTPostOrderTreeVisitor new.
	
	ast acceptVisitor: visitor.
	
	"
	self assertVisitorTop: visitor equals: '2'.
	self assertVisitorStack: visitor equalsStack: { '2'. '^2' }."
]

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> testMessageWithMoreArguments [

	| returnNode visitor |

	returnNode := RBParser parseExpression: ' x arg1: y arg2: z + q'.

	visitor := DASTPostOrderTreeVisitor new.
	returnNode acceptVisitor: visitor.

	self assertVisitorTop: visitor equals: 'x'.
	self assertVisitorStack: visitor equalsStack: #(x y z q 'z+q' 'x arg1: y arg2: z + q')
]

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> testReturnMostLeftNodeInMessageSent [

	| returnNode visitor |

	returnNode := RBParser parseExpression: ' ^ (2 - 3) + 1'.

	visitor := DASTPostOrderTreeVisitor new.
	returnNode acceptVisitor: visitor.

	self assertVisitorTop: visitor equals: '2'.
	self assertVisitorStack: visitor equalsStack: #('2' '3' '2-3' '1' '(2 - 3) + 1' ' ^ (2 - 3) + 1')
]

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> testReturnWithMessageSendStopsInTheReceiver [

	| returnNode visitor |

	returnNode := RBParser parseExpression: ' ^ 2 + 1'.

	visitor := DASTPostOrderTreeVisitor new.
	returnNode acceptVisitor: visitor.

	self assertVisitorTop: visitor equals: '2'.
	self assertVisitorStack: visitor equalsStack: #('2' '1' '2+1' ' ^ 2 + 1')
]

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> testSequence [

	| returnNode visitor |

	returnNode := RBParser parseExpression: ' 
		x := 1.
		x arg1: y arg2: z + q'.

	visitor := DASTPostOrderTreeVisitor new.
	returnNode acceptVisitor: visitor.

	self assertVisitorTop: visitor equals: '1'.
	self assertVisitorStack: visitor equalsStack: #('1' 'x := 1' x y z q 'z+q' 'x arg1: y arg2: z + q' 'x := 1. x arg1: y arg2: z + q')
]

{ #category : #tests }
DASTPostOrderTreeVisitorTest >> testSimpleReturn [

	| ast visitor |
	ast := RBParser parseExpression: ' ^ 2'.
	visitor := DASTPostOrderTreeVisitor new.
	
	ast acceptVisitor: visitor.
	
	self assertVisitorTop: visitor equals: '2'.
	self assertVisitorStack: visitor equalsStack: { '2'. '^2' }.
]

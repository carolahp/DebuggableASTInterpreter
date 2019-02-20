Class {
	#name : #DASTBlock,
	#superclass : #DASTClosure,
	#category : #DebuggableASTInterpreter
}

{ #category : #accessing }
DASTBlock >> initializeWith: aRBNode outerContext: aDASTContext [
	self assert: aRBNode isBlock.
	super initializeWith:  aRBNode outerContext: aDASTContext 
]

{ #category : #accessing }
DASTBlock >> isBlock [ 
	^true
]

{ #category : #accessing }
DASTBlock >> isPrimitive [ 
	"A block always has code inside, and cannot have a primitive declaration "
	^ false
]

{ #category : #accessing }
DASTBlock >> selector [ 
	nodeAST sourceCode
]

{ #category : #accessing }
DASTBlock >> systemClass [ 
	^ BlockClosure
]
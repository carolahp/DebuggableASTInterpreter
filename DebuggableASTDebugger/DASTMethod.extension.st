Extension { #name : #DASTMethod }

{ #category : #'*DebuggableASTDebugger' }
DASTMethod >> methodClass [ 	
	
	^[self nodeAST methodClass] 
		on: Exception 
		do: [:e | (self selector = 'noMethod') 
						ifTrue: [ ^ UndefinedObject ] 
						ifFalse: [ e defaultAction ] ]
]

{ #category : #'*DebuggableASTDebugger' }
DASTMethod >> source [
	^self nodeAST source
]

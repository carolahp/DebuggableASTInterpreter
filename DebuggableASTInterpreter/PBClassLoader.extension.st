Extension { #name : #PBClassLoader }

{ #category : #'*DebuggableASTInterpreter' }
PBClassLoader >> builder [

	^ builder
]

{ #category : #'*DebuggableASTInterpreter' }
PBClassLoader >> systemDefinition [
	^ self builder systemDefinition
]

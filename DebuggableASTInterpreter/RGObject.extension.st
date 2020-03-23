Extension { #name : #RGObject }

{ #category : #'*DebuggableASTInterpreter' }
RGObject >> markAsAccessed [
	
	self 
		propertyNamed: self environment objectAccessedPropertyName 
		put: true
]

{ #category : #'*DebuggableASTInterpreter' }
RGObject >> markAsMaybeAccessed [
	
	self 
		propertyNamed: self environment maybeAccessedPropertyName
		put: true
]

Extension { #name : #RGEnvironment }

{ #category : #'*DebuggableASTInterpreter' }
RGEnvironment >> classNamed: aString ifAbsent: aBlockClosure [ 
	^ (self classNamed: aString) ifNil: [ aBlockClosure value ]
]

{ #category : #'*DebuggableASTInterpreter' }
RGEnvironment >> markMaybeAccessedBehaviorsAsAccessed [
	"We mark as accessed all behaviors that were previously marked as maybe accessed"
	(self ask behaviors
		select: [ :beh | beh propertyNamed: self maybeAccessedPropertyName ifAbsent: [ false ] ])
		do: [ :beh | beh removePropertyNamed: self maybeAccessedPropertyName.
			beh propertyNamed: self objectAccessedPropertyName put: true ]
]

{ #category : #'*DebuggableASTInterpreter' }
RGEnvironment >> maybeAccessedPropertyName [
	^ #maybeAccessed
		
]

{ #category : #'*DebuggableASTInterpreter' }
RGEnvironment >> objectAccessedPropertyName [
	^ objectAccessedPropertyName ifNil: [ objectAccessedPropertyName := #accessed ]
]

{ #category : #'*DebuggableASTInterpreter' }
RGEnvironment >> objectAccessedPropertyName: aString [
	objectAccessedPropertyName := aString
]

{ #category : #'*DebuggableASTInterpreter' }
RGEnvironment >> removeMaybeAccessedPropertyFromAllBehaviors [
	"We remove the property maybeAccessed from all behaviors"
	(self ask behaviors do: [ :beh | beh removePropertyNamed: self maybeAccessedPropertyName ])
		
]

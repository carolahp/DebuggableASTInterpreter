Extension { #name : #CompiledMethod }

{ #category : #'*DebuggableASTInterpreter' }
CompiledMethod >> gtInspectorIn: composite highlightInterval: aCollection [ 
	self gtInspectorSourceIn: composite 
]

{ #category : #'*DebuggableASTInterpreter' }
CompiledMethod >> isKindOfValue [
	^ (201 to: 206) includes: self primitive 
]

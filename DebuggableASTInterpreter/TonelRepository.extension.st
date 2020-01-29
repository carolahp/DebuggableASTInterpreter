Extension { #name : #TonelRepository }

{ #category : #'*DebuggableASTInterpreter' }
TonelRepository >> asRing2EnvironmentWith: packageNames [
	^ self asRingEnvironmentWith: packageNames classes: nil languageDefinition: RGEnvironment 
	
]

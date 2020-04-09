Class {
	#name : #DASTRingEnvironment,
	#superclass : #DASTEnvironment,
	#instVars : [
		'ringEnvironment'
	],
	#classVars : [
		'cachedEnvironment',
		'cachedPackagesNames',
		'cachedPath'
	],
	#category : 'DebuggableASTInterpreter-Environments'
}

{ #category : #initialization }
DASTRingEnvironment >> initializeWithRepositoryLocatedIn: pathString withPackages: packagesNames [ 
	| repository |
	
	(pathString = cachedPath and: [ packagesNames asSet = cachedPackagesNames asSet ])
		ifTrue: [ ^ cachedEnvironment copy ].
	
	repository := TonelRepository new
				directory: pathString asFileReference;
				yourself.
				
	cachedEnvironment := repository asRing2EnvironmentWith: packagesNames.
	cachedPackagesNames := packagesNames.
	cachedPath := pathString.
	
	^ cachedEnvironment copy
]

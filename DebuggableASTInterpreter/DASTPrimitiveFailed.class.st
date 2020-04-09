Class {
	#name : #DASTPrimitiveFailed,
	#superclass : #Error,
	#instVars : [
		'primitiveNumber',
		'receiver'
	],
	#category : 'DebuggableASTInterpreter-Exceptions'
}

{ #category : #instantiation }
DASTPrimitiveFailed class >> primitiveNumber: anInteger receiver: anObject [ 
	^ self new
		primitiveNumber: anInteger; 
		receiver: anObject; 
		yourself
]

{ #category : #signaling }
DASTPrimitiveFailed class >> signalWithPrimitive: anInteger receiver: anObject [
	^(self primitiveNumber: anInteger receiver: anObject) signal
]

{ #category : #accessing }
DASTPrimitiveFailed >> primitiveNumber: anInteger [ 
	primitiveNumber := anInteger
]

{ #category : #accessing }
DASTPrimitiveFailed >> receiver: anObject [ 
	receiver := anObject
]

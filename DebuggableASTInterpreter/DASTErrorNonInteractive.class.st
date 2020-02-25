Class {
	#name : #DASTErrorNonInteractive,
	#superclass : #Object,
	#instVars : [
		'messageText',
		'exception'
	],
	#category : #'DebuggableASTInterpreter-Exceptions'
}

{ #category : #accessing }
DASTErrorNonInteractive >> exception [
	^ exception
]

{ #category : #accessing }
DASTErrorNonInteractive >> exception: anObject [
	exception := anObject
]

{ #category : #signalling }
DASTErrorNonInteractive >> signal [ 
	"the next call returns the value I'm expecting. The excecution will stop at this point. This is hold with alfileres"
	thisContext unhandledException: self exception.
	

]

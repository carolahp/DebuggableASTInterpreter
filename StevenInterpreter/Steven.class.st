Class {
	#name : #Steven,
	#superclass : #Object,
	#classVars : [
		'x'
	],
	#category : #StevenInterpreter
}

{ #category : #'as yet unclassified' }
Steven >> classVarX [
	^ x ifNil: [ x:=42 ]
]

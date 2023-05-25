# Bacon Number Database

This is the initial commit, better README to follow.

## Introduction

The Bacon number of an actor is the number of degrees of separation he or she has from Bacon, as defined by the game. This is an application of the Erdős number concept to the Hollywood movie industry. The higher the Bacon number, the greater the separation from Kevin Bacon the actor is.

The goal of this is to build a database of each actor's Bacon Numbers from their first film to present, with the dates and movies when their movies changed.

## Methodology

Actors must be connected by theatrically-released films in which they held a credited acting role.

Connections are calculated using a Breadth-First Search.

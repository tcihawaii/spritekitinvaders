//
//  Settings.swift
//  Cosmic Attackers
//
//  Created by Derek Smith on 1/14/23.
//


enum Sprite:UInt32 {
    case player = 0b1
    case enemy = 0b10
    case wall = 0b100
    case playerBullet = 0b1000
    case enemyBullet = 0b10000
}

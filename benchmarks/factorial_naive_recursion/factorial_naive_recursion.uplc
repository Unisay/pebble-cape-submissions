(program 1.1.0

(case
  (constr 0
    [
      [
        (builtin addInteger) 
        (con integer -1)
      ],

      [
        (builtin lessThanInteger) 
        (con integer 1)
      ],

      (force (builtin ifThenElse))
    ]
  )
  [
    (lam a 
      (lam b 
        (lam c 
          [
            (lam d 
              [
                d 
                d
              ]
            ) 
            (lam d 
              (lam e 
                (force 
                  (case
                    (constr 0
                      [
                        [
                          b 
                          e
                        ],

                        (delay 
                          [
                            [
                              (builtin multiplyInteger) 
                              e
                            ] 
                            [
                              [
                                d 
                                d
                              ] 
                              [
                                a 
                                e
                              ]
                            ]
                          ]
                        ),

                        (delay 
                          (con integer 1)
                        )
                      ]
                    )
                    [
                      c
                    ]

                  )
                )
              )
            )
          ]
        )
      )
    )
  ]

)
)
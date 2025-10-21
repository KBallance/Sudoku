(define (problem lunar-mission-1)
    (:domain lunar)

    (:objects
        l - lander
        r - rover

        l1 l2 l3 l4 l5 - location

        d1 - image
        d2 - scan
        
        s1 - sample
    )

    (:init
        ;start config
        (flying l)
        (carrying l r)
        (storeEmpty l)
        
        (undeployed r)
        (storeEmpty r)
        (memEmpty r)

        ;map
        (path l1 l2)
        (path l1 l4)
        (path l2 l3)
        (path l3 l5)
        (path l4 l3)
        (path l5 l1)
        ;points of interest
        (located d1 l5)
        (located d2 l3)
        (located s1 l1)
    )

    (:goal
        (and
            (heldData d1 l)
            (heldData d2 l)
            (heldSample s1 l)
        )
    )
)
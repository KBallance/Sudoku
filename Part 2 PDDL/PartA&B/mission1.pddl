(define (problem lunar-mission-1)
    (:domain lunar)

    (:objects
        l - lander
        r - rover

        wp1 wp2 wp3 wp4 wp5 - location

        img - image
        scan - scan
        
        s1 - sample
    )

    (:init
        ;start config
        (flying l)
        (carrying l r)
        (commands l r)
        (storeEmpty l)
        
        (undeployed r)
        (storeEmpty r)
        (memEmpty r)

        ;map
        (path wp1 wp2)
        (path wp1 wp4)
        (path wp2 wp3)
        (path wp3 wp5)
        (path wp4 wp3)
        (path wp5 wp1)
        
        ;points of interest
        (located img wp5) ;image POI located at wp5
        (located scan wp3) ;scan POI located at wp3
        (located s1 wp1) ;sample located at wp1
    )

    (:goal
        (and
            (heldData l img) ;image saved in lander
            (heldData l scan) ; scan saved in lander
            (heldSample l s1) ; sample stored in lander
        )
    )
)
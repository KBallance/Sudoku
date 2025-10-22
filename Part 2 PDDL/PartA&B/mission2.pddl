(define (problem lunar-mission-2)
    (:domain lunar)

    (:objects
        wp1 wp2 wp3 wp4 wp5 wp6 - location

        l1 l2 - lander
        r1 r2 - rover

        img1 img2 - image
        scan1 scan2 - scan

        smpl1 smpl2 - sample
    )

    (:init
        ;map
        (path wp1 wp2)
        (path wp2 wp1)
        (path wp2 wp3)
        (path wp2 wp4)
        (path wp3 wp5)
        (path wp4 wp2)
        (path wp5 wp3)
        (path wp5 wp6)
        (path wp6 wp4)

        ;landers
        (landed l1)
        (not (carrying l1 r1))
        (commands l1 r1)
        (storeEmpty l1)
        (located l1 wp2)

        (flying l2)
        (carrying l2 r2)
        (commands l2 r2)
        (storeEmpty l2)

        ;rovers
        (deployed r1)
        (storeEmpty r1)
        (memEmpty r1)
        (located r1 wp2)

        (undeployed r2)
        (storeEmpty r2)
        (memEmpty r2)

        ;points of interest
        (located img1 wp3)
        (located scan1 wp4)
        (located img2 wp2)
        (located scan2 wp6)
        (located smpl1 wp5)
        (located smpl2 wp1)
    )

    (:goal
        (and
            ;ensure it uses all rovers
            ; (deployed r1)
            ; (deployed r2)
            ;all data transmitted to landers
            (transmitted img1)
            (transmitted img2)
            (transmitted scan1)
            (transmitted scan2)
            ;all samples collected
            ; (sampleDeposited smpl1)
            ; (sampleDeposited smpl2)
        )
    )
)
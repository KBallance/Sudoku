(define (domain lunar-extended)
    (:requirements :strips :typing)

    (:types
        vehicle - object
        lander rover - vehicle

        location - object

        data - object
        image scan - data

        sample - object

        astronaut - object
    )

    (:predicates
        (flying ?l - lander); lander in flight
        (landed ?l - lander); lander stationary
        
        (carrying ?l - lander ?r - rover); lander is carrying certain rover
        (commands ?l - lander ?r - rover);lander commands a rover (they are connected)

        (undeployed ?r - rover); rover not ready
        (deployed ?r - rover); rover ready

        (path ?l1 - location ?l2 - location); path exists between 1 & 2
        (located ?x - object ?l - location) ; object is in this location
        
        (heldSample ?v - vehicle ?sa - sample); sample held in vehicle storage
        (storeEmpty ?v - vehicle); rover not holding sample

        (memEmpty ?v - vehicle); vehicle not holding data
        (heldData ?v - vehicle ?d - data); data stored in vehicle memory

        (transmitted ?d - data); img/scan has been transmitted to a lander
        (sampleDeposited ?s - sample); sample has been deposited in a lander

        (inControlRoom ?l - lander ?a - astronaut); astronaut is in lander control rool
        (inDockingBay ?l - lander ?a - astronaut); astronaut is in lander docking bay
    )

    (:action land_lander; land lander at any location
        :parameters (?l - lander ?lo - location)
        :precondition (and
            (flying ?l)
        )
        :effect (and
            (landed ?l)
            (not (flying ?l))
            (located ?l ?lo)
        )
    )

    (:action deploy_rover; deploy rover from lander that was carrying it (if astronaut in docking bay)
        :parameters (?l - lander ?a - astronaut ?r - rover ?lo - location)
        :precondition (and
            (landed ?l)
            (carrying ?l ?r)
            (commands ?l ?r)
            (located ?l ?lo)
            (undeployed ?r)

            (inDockingBay ?l ?a)
        )
        :effect (and
            (not (carrying ?l ?r))

            (not (undeployed ?r))
            (deployed ?r)
            (located ?r ?lo)
        )
    )

    (:action move_rover; move rover from one location to another
        :parameters (?r - rover ?l1 - location ?l2 - location)
        :precondition (and
            (deployed ?r)
            (located ?r ?l1)
            (path ?l1 ?l2)
        )
        :effect (and
            (not (located ?r ?l1))
            (located ?r ?l2)
        )
    )

    (:action capture_image; rover takes image at location & stores data in memory
        :parameters (?r - rover ?l - location ?i - image)
        :precondition (and
            (deployed ?r)
            (located ?r ?l)
            (located ?i ?l)
            (memEmpty ?r)
        )
        :effect (and
            (heldData ?r ?i)
            (not (memEmpty ?r))

            (not (located ?i ?l)); assumed data can only be collected once
        )
    )
    
    (:action scan_radar; rover takes scan at location & stores data in memory
        :parameters (?r - rover ?l - location ?s - scan)
        :precondition (and
            (deployed ?r)
            (located ?r ?l)
            (located ?s ?l)
            (memEmpty ?r)
        )
        :effect (and
            (heldData ?r ?s)
            (not (memEmpty ?r))

            (not (located ?s ?l)); assumed data can only be collected once
        )
    )

    (:action transmit_data; rover transmits held data to its lander (if astronaut in control room)
        :parameters (?r - rover ?l - lander ?a - astronaut ?d - data)
        :precondition (and
            (commands ?l ?r)

            (deployed ?r)
            (heldData ?r ?d)

            (inControlRoom ?l ?a)
        )
        :effect (and
            (not (heldData ?r ?d))
            (memEmpty ?r)

            (heldData ?l ?d)
            
            (transmitted ?d)
        )
    )

    (:action collect_sample; rover collects sample from location
        :parameters (?r - rover ?l - location ?sa - sample)
        :precondition (and
            (deployed ?r)
            (located ?r ?l)
            (located ?sa ?l)
            (storeEmpty ?r)
        )
        :effect (and
            (heldSample ?r ?sa)
            (not (storeEmpty ?r))

            (not (located ?sa ?l)); assumed sample can only be collected once
        )
    )

    (:action deposit_sample; put sample from rover into its lander (if astronaut in docking bay)
        :parameters (?r - rover ?l - lander ?a - astronaut ?lo - location ?sa - sample)
        :precondition (and
            (landed ?l)
            (located ?l ?lo)
            (commands ?l ?r)
            (storeEmpty ?l)

            (deployed ?r)
            (located ?r ?lo)
            (heldSample ?r ?sa)

            (inDockingBay ?l ?a)
        )
        :effect (and
            (not (heldSample ?r ?sa))
            (storeEmpty ?r)

            (heldSample ?l ?sa)
            (not (storeEmpty ?l))
            
            (sampleDeposited ?sa)
        )
    )

    (:action move_astronaut_to_controls; moves astronaut in lander to control room
        :parameters (?a - astronaut ?l - lander)
        :precondition (and
            (inDockingBay ?l ?a)
        )
        :effect (and
            (not (inDockingBay ?l ?a))
            (inControlRoom ?l ?a)
        )
    )

    (:action move_astronaut_to_docking; moves astronaut in lander to docking bay
        :parameters (?a - astronaut ?l - lander)
        :precondition (and
            (inControlRoom ?l ?a)
        )
        :effect (and
            (not (inControlRoom ?l ?a))
            (inDockingBay ?l ?a)
        )
    )
)
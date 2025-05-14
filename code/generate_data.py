import random
from datetime import datetime, date, timedelta, time
from collections import defaultdict
from faker import Faker

#This is our python dummy data generator.

fake = Faker()
random.seed(42)  # For reproducible results

class DataGenerator:
    def __init__(self):
        # Initialize all data containers
        self.festivals = []
        self.locations = []
        self.stages = []
        self.equipment = []
        self.stage_equipment = []
        self.events = []
        self.artists = []
        self.groups = []
        self.artist_group_members = []
        self.genres = []
        self.artist_genres = []
        self.performances = []
        self.visitors = []
        self.tickets = []
        self.reviews = []
        self.staff = []
        self.staff_assignments = []
        self.resale_interest = []
        self.group_performance_years = defaultdict(list)
        
        # Track artist performance history
        self.artist_performance_years = defaultdict(list)
        self.festival_years = {}  # Maps festival_id to year

    def generate_festivals(self, count=10):
        current_year = datetime.now().year
        # Generate 8 past years and 2 future years
        past_years = [current_year - i for i in range(1, 9)]  # Last 8 years
        future_years = [current_year + 1, current_year + 2]
        all_years = past_years + future_years
        
        assert len(all_years) == count, "Incorrect number of years generated"
        
        for i in range(count):
            year = all_years[i]
            festival = {
                'festival_id': i + 1,
                'location_id': random.choice([loc['location_id'] for loc in self.locations]),
                'name': f'Pulse University {year}',
                'year': year,
                'duration_days': random.randint(1, 7),
                'poster_image': f'poster_{i+1}.jpg',
                'description': fake.sentence()
            }
            self.festivals.append(festival)
            self.festival_years[festival['festival_id']] = year
        
    def generate_artists(self, count=50):
        """Generate artists with sequential IDs"""
        self.artists = []
        for i in range(1, count+1):
            self.artists.append({
                'artist_id': i,
                'name': fake.name(),
                'stage_name': fake.user_name(),
                'dob': fake.date_of_birth(minimum_age=18, maximum_age=60),
                'website': fake.url(),
                'instagram': f'@{fake.user_name()}',
                'photo': f'artist_{i}.jpg'
            })
    
    def generate_groups(self, count=10):
        """Generate groups with explicit IDs (AUTO_INCREMENT in DB)"""
        self.groups = []
        for idx in range(count):
            self.groups.append({
                'group_id': idx + 1,
                'name': fake.company(),
                'formation_date': fake.date_between(
                    start_date='-20y', end_date='today'
                ),
                'website': fake.url(),
                'photo': f'group_{fake.uuid4()}.jpg'
            })

    
    def assign_artists_to_groups(self):
        """Assign artists to groups with possible multiple group memberships"""
        self.artist_group_members = []
        
        # Assign artists to groups (can be in multiple groups)
        for group in self.groups:
            group_id = group['group_id']
            available_artists = self.artists.copy()
            num_members = random.randint(3, 5)
            members = random.sample(available_artists, num_members)
            
            for artist in members:
                self.artist_group_members.append({
                    'group_id': group_id,
                    'artist_id': artist['artist_id']
                })

    def generate_locations(self, count=10):
        """
        Create 'count' locations, guaranteeing at least one per continent,
        then filling the rest at random.
        """
        continents = ['Europe', 'Asia', 'North America', 
                      'South America', 'Africa', 'Australia']
        self.locations = []

        # Assign one location per continent first
        for idx, cont in enumerate(continents):
            if idx >= count:
                break
            self.locations.append({
                'location_id': idx + 1,
                'address': fake.address(),
                'latitude': float(fake.latitude()),
                'longitude': float(fake.longitude()),
                'city': fake.city(),
                'country': fake.country(),
                'continent': cont
            })

        # Fill remaining slots randomly
        for i in range(len(self.locations) + 1, count + 1):
            self.locations.append({
                'location_id': i,
                'address': fake.address(),
                'latitude': float(fake.latitude()),
                'longitude': float(fake.longitude()),
                'city': fake.city(),
                'country': fake.country(),
                'continent': random.choice(continents)
            })


    def generate_stages(self, count=30):
        used_names = set()
        for _ in range(count):
            while True:
                name = f"{fake.color_name()} {fake.street_suffix()}"
                if name not in used_names:
                    used_names.add(name)
                    break
                    
            self.stages.append({
                'stage_id': len(self.stages) + 1,
                'festival_id': random.choice([f['festival_id'] for f in self.festivals]),
                'name': name,
                'description': fake.sentence(),
                'capacity': random.randint(8, 10),
                'image': f'stage_{fake.uuid4()}.jpg'
            })

    def generate_equipment(self):
        equipment_types = ['Speakers', 'Lights', 'Microphones', 'Consoles', 'Effects']
        for i, eq in enumerate(equipment_types, 1):
            self.equipment.append({
                'equipment_id': i,
                'type': eq,
                'description': f'Professional {eq} for stage use',
                'image': f'{eq.lower()}.jpg'
            })

    def generate_stage_equipment(self):
        equipment_ids = [e['equipment_id'] for e in self.equipment]
    
        for stage in self.stages:
            # Ensure we don't request more equipment than exists
            num_equipment = random.randint(3, min(6, len(equipment_ids)))  # Never exceed available equipment
        
            # Get unique equipment IDs for this stage
            selected_equipment = random.sample(equipment_ids, num_equipment)
        
            for eq_id in selected_equipment:
                self.stage_equipment.append({
                    'stage_id': stage['stage_id'],
                    'equipment_id': eq_id,
                    'quantity': random.randint(1, 10)
                })

    def generate_genres(self):
        genre_data = [
            (1, 'Rock', 'Hard Rock'),
            (2, 'Jazz', 'Bebop'),
            (3, 'Pop', 'Synthpop'),
            (4, 'Electronic', 'Techno'),
            (5, 'Hip Hop', 'Trap')
        ]
        for g in genre_data:
            self.genres.append({
                'genre_id': g[0],
                'name': g[1],
                'subgenre': g[2]
            })

    def generate_artist_genres(self):
        for artist in self.artists:
            num_genres = random.randint(1, 3)
            selected_genres = random.sample(self.genres, num_genres)
            for genre in selected_genres:
                self.artist_genres.append({
                    'artist_id': artist['artist_id'],
                    'genre_id': genre['genre_id']
                })

    def generate_events(self):
        event_id = 1
        for festival in self.festivals:
            festival_id = festival['festival_id']
            # Get stages belonging to this festival
            stages_in_festival = [s for s in self.stages if s['festival_id'] == festival_id]
            if not stages_in_festival:
                continue  # Skip if no stages available
            
            used_stage_dates = set()
            for _ in range(random.randint(5, 10)):
                while True:
                    # Select a stage from this festival's stages
                    stage = random.choice(stages_in_festival)
                    stage_id = stage['stage_id']
                    # Generate event date within the festival's year
                    event_date = fake.date_between(
                        start_date=datetime(festival['year'], 1, 1),
                        end_date=datetime(festival['year'], 12, 31)
                    )
                    # Check if (stage_id, event_date) is already used
                    if (stage_id, event_date) not in used_stage_dates:
                        used_stage_dates.add((stage_id, event_date))
                        break
                
                self.events.append({
                    'event_id': event_id,
                    'festival_id': festival_id,
                    'stage_id': stage_id,
                    'event_date': event_date,
                    'total_duration': timedelta(hours=random.randint(4, 12))
                })
                event_id += 1

    def generate_performances(self):
        performance_types = ['warm up', 'headline', 'special guest']
        performance_id = 1
        self.performance_members = []

        # Track which artists are in groups
        artists_in_groups = {m['artist_id'] for m in self.artist_group_members}

        # --- Original random scheduling logic ---
        for event in self.events:
            fest_id = event['festival_id']
            current_year = self.festival_years[fest_id]

            # Solo artists eligible (not in a group, and no 4-year streak)
            eligible_solo = [
                a['artist_id'] for a in self.artists
                if a['artist_id'] not in artists_in_groups
                and not self._has_three_consecutive(a['artist_id'], current_year, is_artist=True)
            ]
            # Groups eligible (no 4-year streak)
            eligible_groups = [
                g['group_id'] for g in self.groups
                if not self._has_three_consecutive(g['group_id'], current_year, is_artist=False)
            ]

            performers = [('artist', aid) for aid in eligible_solo] + \
                         [('group', gid)  for gid in eligible_groups]
            if not performers:
                continue

            event_date = event['event_date']
            start_time = datetime.combine(event_date, time(18, 0))
            end_time = start_time + event['total_duration']

            max_performances = random.randint(3, 5)
            performance_count = 0

            while performance_count < max_performances and start_time < end_time:
                if not performers:
                    break

                performer_type, performer_id = random.choice(performers)

                # Record that this performer has played this year
                if performer_type == 'artist':
                    self.artist_performance_years[performer_id].append(current_year)
                else:
                    self.group_performance_years[performer_id].append(current_year)

                # Pick a duration
                duration = timedelta(minutes=random.randint(30, 120))
                if start_time + duration > end_time:
                    break  # Not enough time remaining

                # Create the performance row
                self.performances.append({
                    'performance_id': performance_id,
                    'event_id': event['event_id'],
                    'start_time': start_time.strftime('%Y-%m-%d %H:%M:%S'),
                    'stage_id': event['stage_id'],
                    'duration': str(duration),
                    'type': random.choice(performance_types)
                })

                # Link artists to performance (solo or group members)
                if performer_type == 'artist':
                    self.performance_members.append({
                        'performance_id': performance_id,
                        'artist_id': performer_id,
                        'group_id': None
                    })
                else:
                    group_members = [
                        m['artist_id'] for m in self.artist_group_members
                        if m['group_id'] == performer_id
                    ]
                    for artist_id in group_members:
                        self.performance_members.append({
                            'performance_id': performance_id,
                            'artist_id': artist_id,
                            'group_id': performer_id
                        })

                performance_id += 1
                performance_count += 1

                # Advance start_time
                if performance_count < max_performances:
                    break_time = timedelta(minutes=random.randint(5, 30))
                    start_time += duration + break_time
                else:
                    start_time += duration

        # --- Guarantee at least 5 artists span 3 continents ---
        N = 5
        # Build festival→continent map
        fest_cont = {
            f['festival_id']: next(
                loc['continent']
                for loc in self.locations
                if loc['location_id'] == f['location_id']
            )
            for f in self.festivals
        }
        # Collect continents per artist
        artist_conts = defaultdict(set)
        for pm in self.performance_members:
            perf = next(p for p in self.performances if p['performance_id'] == pm['performance_id'])
            evt  = next(e for e in self.events       if e['event_id']       == perf['event_id'])
            artist_conts[pm['artist_id']].add(fest_cont[evt['festival_id']])

        # Pick up to N artists who have <3 continents so far
        candidates = [
            aid for aid in artist_conts
            if len(artist_conts[aid]) < 3
        ]
        random.shuffle(candidates)
        featured = candidates[:N]

        next_perf_id = max(p['performance_id'] for p in self.performances) + 1

        for artist_id in featured:
            have = artist_conts[artist_id]
            missing = [c for c in set(fest_cont.values()) if c not in have]
            # Add performances until they reach 3 continents
            for cont in missing[:3 - len(have)]:
                # Choose a festival in that continent
                fids = [fid for fid, cc in fest_cont.items() if cc == cont]
                fid = random.choice(fids)

                # Pick an existing event
                evts = [e for e in self.events if e['festival_id'] == fid]
                if not evts:
                    continue
                evt = random.choice(evts)

                perf = {
                    'performance_id': next_perf_id,
                    'event_id': evt['event_id'],
                    'start_time': datetime.combine(evt['event_date'], time(20, 0))\
                                  .strftime('%Y-%m-%d %H:%M:%S'),
                    'stage_id': evt['stage_id'],
                    'duration': str(timedelta(minutes=60)),
                    'type': 'special guest'
                }
                self.performances.append(perf)
                self.performance_members.append({
                    'performance_id': next_perf_id,
                    'artist_id': artist_id,
                    'group_id': None
                })
                next_perf_id += 1

    # The rest of the methods remain unchanged (generate_locations, generate_stages, generate_equipment, etc.)

    def _has_three_consecutive(self, performer_id, current_year, is_artist=True):
        years = self.artist_performance_years if is_artist else self.group_performance_years
        existing_years = sorted(list(set(years.get(performer_id, []))))
        test_years = existing_years + [current_year]
        
        # Check for 4 consecutive years
        consecutive = 1
        for i in range(1, len(test_years)):
            if test_years[i] == test_years[i-1] + 1:
                consecutive += 1
                if consecutive >= 4:
                    return True
            else:
                consecutive = 1
        return False
            

    def generate_visitors(self, count=150):
        for i in range(1, count+1):
            self.visitors.append({
                'visitor_id': i,
                'first_name': fake.first_name(),
                'last_name': fake.last_name(),
                'email': fake.unique.email(),
                'phone': fake.phone_number(),
                'age': random.randint(18, 80)
            })

    def generate_tickets(self, count=400):
        existing_pairs = {(t['visitor_id'], t['event_id']) for t in self.tickets}
        event_counts = defaultdict(int)
        vip_counts = defaultdict(int)
        for t in self.tickets:
            event_counts[t['event_id']] += 1
            if t['ticket_category'] == 'VIP':
                vip_counts[t['event_id']] += 1

        ticket_id = max((t['ticket_id'] for t in self.tickets), default=0) + 1
        initial_interest = len(self.resale_interest)
        while len(self.tickets) < count:
            event = random.choice(self.events)
            visitor = random.choice(self.visitors)
            pair = (visitor['visitor_id'], event['event_id'])
            if pair in existing_pairs:
                continue
            existing_pairs.add(pair)

            # --- FIXED date range logic ---
            event_date = event['event_date']
            today = date.today()
            if event_date > today:
                end_date = today
                start_date = today - timedelta(days=180)
            else:
                end_date = event_date
                start_date = event_date - timedelta(days=180)
            if start_date >= end_date:
                start_date = end_date - timedelta(days=1)
            # ------------------------------

            stage = next(s for s in self.stages if s['stage_id'] == event['stage_id'])
            capacity = stage['capacity']
            eid = event['event_id']

            # Sold-out → resale_interest
            if event_counts[eid] >= capacity:
                category = 'VIP' if random.random() < 0.1 else random.choice(['general', 'backstage'])
                self.resale_interest.append({
                    'interested_visitor_id': visitor['visitor_id'],
                    'event_id': eid,
                    'ticket_category': category,
                        # pick a random datetime between 90 days before today and now:
                    'expressed_on': fake.date_time_between(start_date='-90d', end_date='now')
                                          .strftime('%Y-%m-%d %H:%M:%S')

                })
                continue
            new_interest = len(self.resale_interest) - initial_interest

            # VIP allocation
            max_vip = int(0.1 * capacity)
            current_vip = vip_counts.get(eid, 0)
            is_vip = current_vip < max_vip and random.random() < 0.1

            ticket_data = {
                'ticket_id': ticket_id,
                'event_id': eid,
                'visitor_id': visitor['visitor_id'],
                'ticket_category': 'VIP' if is_vip else random.choice(['general', 'backstage']),
                'price': round(random.uniform(200, 500), 2) if is_vip else round(random.uniform(50, 200), 2),
                'purchase_date': fake.date_between(start_date=start_date, end_date=end_date).strftime('%Y-%m-%d'),
                'payment_method': random.choice(['credit_card', 'debit_card', 'bank_transfer']),
                'ean_code': fake.ean13(),
                'activated': random.choice([True, False])
            }

            if is_vip:
                vip_counts[eid] += 1
            event_counts[eid] += 1
            self.tickets.append(ticket_data)
            ticket_id += 1
        print(f"Inserted {new_interest} rows into resale_interest")


    def generate_reviews(self):
        review_id = 1
        existing_pairs = set()  # Track (visitor_id, performance_id) pairs
        
        for ticket in self.tickets:
            if ticket['activated'] and random.random() < 0.7:
                performance = random.choice(self.performances)
                pair = (ticket['visitor_id'], performance['performance_id'])
                
                if pair in existing_pairs:
                    continue
                    
                existing_pairs.add(pair)
                
                self.reviews.append({
                    'review_id': review_id,
                    'visitor_id': ticket['visitor_id'],
                    'performance_id': performance['performance_id'],
                    'interpretation': random.randint(1, 5),
                    'lights_sound': random.randint(1, 5),
                    'stage_presence': random.randint(1, 5),
                    'organization': random.randint(1, 5),
                    'overall_impression': random.randint(1, 5)
                })
                review_id += 1

    def generate_staff(self, count=50):
        # Generate 20 security, 20 support, and 10 technicians
        roles = ['security']*20 + ['support']*20 + ['technician']*10
        random.shuffle(roles)
        
        exp_levels = ['intern', 'junior', 'average', 'experienced', 'senior']
        for i in range(1, count+1):
            self.staff.append({
                'staff_id': i,
                'name': fake.name(),
                'age': random.randint(18, 65),
                'staff_role': roles[i-1],
                'experience_level': random.choice(exp_levels)
            })

    def generate_staff_assignments(self):
        assignment_id = 1
        for event in self.events:
            stage = next(s for s in self.stages if s['stage_id'] == event['stage_id'])
            
            # Staff requirements
            security_needed = max(1, int(stage['capacity'] * 0.05))  # 5%
            support_needed = max(1, int(stage['capacity'] * 0.02))   # 2%
            technicians_needed = random.randint(2, 5)  # Fixed number of technicians
            
            # Get available staff
            security_staff = [s for s in self.staff if s['staff_role'] == 'security']
            support_staff = [s for s in self.staff if s['staff_role'] == 'support']
            tech_staff = [s for s in self.staff if s['staff_role'] == 'technician']
            
            # Assign staff
            security = random.sample(security_staff, min(security_needed, len(security_staff)))
            support = random.sample(support_staff, min(support_needed, len(support_staff)))
            technicians = random.sample(tech_staff, min(technicians_needed, len(tech_staff)))
            
            # Create assignments
            for staff in security + support + technicians:
                self.staff_assignments.append({
                    'assignment_id': assignment_id,
                    'staff_id': staff['staff_id'],
                    'event_id': event['event_id'],
                    'assignment_date': event['event_date'],
                    'staff_role': staff['staff_role']
                })
                assignment_id += 1

    def save_to_sql(self):
        """Generate SQL with proper insertion order and NULL handling"""
        with open('load.sql', 'w') as f:
            tables = [
                ('Location', self.locations),
                ('Festival', self.festivals),
                ('Stage', self.stages),
                ('Equipment', self.equipment),
                ('Stage_Equipment', self.stage_equipment),
                ('Artist_Group', self.groups),
                ('Artist', self.artists),
                ('Artist_Group_Members', self.artist_group_members),
                ('Genre', self.genres),
                ('Artist_Genres', self.artist_genres),
                ('Event', self.events),
                ('Performance', self.performances),
                ('performance_members', self.performance_members),
                ('Visitor', self.visitors),
                ('Ticket', self.tickets),
                ('resale_interest', self.resale_interest),
                ('Review', self.reviews),
                ('Staff', self.staff),
                ('Staff_Assignment', self.staff_assignments)
            ]

            for table_name, data in tables:
                if not data:
                    continue

                columns = ', '.join(data[0].keys())
                f.write(f'INSERT INTO {table_name} ({columns}) VALUES\n')
                
                for i, row in enumerate(data):
                    values = []
                    for key, val in row.items():
                        if val is None:
                            values.append('NULL')
                        elif isinstance(val, (datetime, date)):
                            values.append(f"'{val.strftime('%Y-%m-%d')}'")
                        elif isinstance(val, timedelta):
                            values.append(f"'{str(val)}'")
                        elif isinstance(val, str):
                            values.append(f"'{val}'")
                        else:
                            values.append(str(val))
                    
                    line = f'({", ".join(values)})'
                    f.write(line + (',\n' if i < len(data)-1 else ';\n\n'))

if __name__ == '__main__':
    generator = DataGenerator()
    
    # Generate in dependency order
    generator.generate_locations(10)
    generator.generate_festivals(10)
    generator.generate_stages(30)
    generator.generate_equipment()
    generator.generate_stage_equipment()
    
    # Artist/Group generation sequence
    generator.generate_artists(50)
    generator.generate_groups(10)
    generator.assign_artists_to_groups()
    
    # Generate remaining data
    generator.generate_genres()
    generator.generate_artist_genres()
    generator.generate_events()
    generator.generate_performances()
    generator.generate_visitors(150)
    generator.generate_tickets(400)
    generator.generate_reviews()
    generator.generate_staff(50)
    generator.generate_staff_assignments()
    
    generator.save_to_sql()
    print("SQL generation complete. Check load.sql")
-- Stores information about individuals who receive donations or participate in campaigns.
CREATE TABLE
    "Recipient" (
        -- Unique identifier for each recipient.
        "id" UUID PRIMARY KEY,
        -- Recipient's first name.
        "firstName" VARCHAR(50) NOT NULL,
        -- Recipient's middle name (father's name).
        "middleName" VARCHAR(50) NOT NULL,
        -- Recipient's last name (grandfather's name).
        "lastName" VARCHAR(50) NOT NULL,
        -- Recipient's date of birth.
        "dateOfBirth" DATE NOT NULL,
        -- Recipient's email address. This is not required.
        "email" VARCHAR(100),
        -- Recipient's phone number.
        "phoneNo" VARCHAR(20) NOT NULL UNIQUE,
        -- Hashed password for security.
        "passwordHash" VARCHAR(255) NOT NULL,
        -- Number of failed login attempts.
        "loginAttempts" INTEGER DEFAULT 0,
        -- Timestamp when the account was locked due to failed attempts.
        "accountLockDate" TIMESTAMP,
        -- A short biography or description of the recipient.
        "bio" TEXT,
        -- URL to the recipient's profile picture.
        "profilePictureUrl" TEXT
    );

-- Links recipients to their social media accounts.
CREATE TABLE
    "RecipientSocialMediaHandles" (
        -- Unique identifier for each social media handle.
        "handleId" UUID PRIMARY KEY,
        /* DOC-UPDATE: Changed type to TEXT to bypass URL length limits. */
        -- The social media handle url.
        "socialMediaHandle" TEXT NOT NULL,
        -- Foreign key referencing the Recipient table.
        "recipientId" UUID NOT NULL REFERENCES "Recipient" ("id") ON DELETE CASCADE ON UPDATE CASCADE
    );

-- Stores information about supervisors.
CREATE TABLE
    "Supervisor" (
        -- Unique identifier for each supervisor.
        "id" UUID PRIMARY KEY,
        -- Supervisor's first name.
        "firstName" VARCHAR(50) NOT NULL,
        -- Supervisor's middle name (father's name).
        "middleName" VARCHAR(50) NOT NULL,
        -- Supervisor's last name (grandfather's name).
        "lastName" VARCHAR(50) NOT NULL,
        -- Supervisor's date of birth.
        "dateOfBirth" DATE NOT NULL,
        -- Supervisor's email address.
        "email" VARCHAR(100) NOT NULL,
        -- Supervisor's phone number.
        "phoneNo" VARCHAR(20) NOT NULL,
        -- Hashed password for security.
        "passwordHash" VARCHAR(255) NOT NULL,
        -- Number of failed login attempts.
        "loginAttempts" INTEGER DEFAULT 0,
        -- Timestamp when the account was locked with time zone.
        "accountLockDate" TIMESTAMPTZ
    );

-- Stores notifications sent to recipients or supervisors.
CREATE TABLE
    "Notification" (
        -- Unique identifier for each notification.
        "id" UUID PRIMARY KEY,
        -- Subject/header of the notification.
        "subject" VARCHAR(255) NOT NULL,
        -- Content of the notification.
        "body" TEXT,
        -- Indicates whether the notification has been read.
        "isRead" BOOLEAN NOT NULL,
        -- Timestamp when the notification was issued with time zone.
        "timestamp" TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        -- Foreign key referencing the Recipient table.
        "recipientId" UUID REFERENCES "Recipient" ("id"),
        -- Foreign key referencing the Supervisor table.
        "supervisorId" UUID REFERENCES "Supervisor" ("id"),
        -- A notification can belong either to a recipient or a supervisor. (i.e. recipientId or supervisorId must be set, but not both).
        CHECK (
            (
                "recipientId" IS NOT NULL
                AND "supervisorId" IS NULL
            )
            OR (
                "recipientId" IS NULL
                AND "supervisorId" IS NOT NULL
            )
        )
    );

-- Encapsulates the possible statuses of a campaign.
CREATE TYPE "CampaignStatus" AS ENUM (
    'PENDING_REVIEW',
    'VERIFIED',
    'DENIED',
    'LIVE',
    'PAUSED',
    'COMPLETED'
);

-- Stores information about campaigns.
CREATE TABLE
    "Campaign" (
        -- Unique identifier for each campaign.
        "id" UUID PRIMARY KEY,
        -- Title of the campaign.
        "title" VARCHAR(100) NOT NULL,
        -- Description of the campaign.
        "description" TEXT NOT NULL,
        -- Fundraising goal for the campaign.
        "fundraisingGoal" BIGINT NOT NULL,
        -- Current status of the campaign.
        "status" "CampaignStatus" NOT NULL,
        -- Category of the campaign.
        "category" VARCHAR(100) NOT NULL,
        -- Payment method used (e.g., TeleBirr, CBEBirr, Phone transfer, etc.).
        "paymentMethod" VARCHAR(100) NOT NULL,
        -- Phone number associated with the payment method (if applicable).
        "phoneNo" VARCHAR(20),
        -- Bank account number (if applicable).
        "bankAccountNo" VARCHAR(16),
        -- Bank name (if applicable).
        "bankName" VARCHAR(50),
        -- Timestamp when the campaign was submitted with time zone.
        "submissionDate" TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        -- Timestamp when the campaign was verified with time zone.
        "verificationDate" TIMESTAMPTZ,
        -- Timestamp when the campaign was denied with time zone.
        "denialDate" TIMESTAMPTZ,
        -- Timestamp when the campaign was launched with time zone.
        "launchDate" TIMESTAMPTZ,
        -- End date of the campaign with time zone.
        "endDate" TIMESTAMPTZ,
        -- Foreign key referencing the Recipient table (campaign owner).
        "ownerRecipientId" UUID NOT NULL REFERENCES "Recipient" ("id"),
        -- Foreign key referencing the Supervisor table (managing supervisor).
        "managingSupervisorId" UUID NOT NULL REFERENCES "Supervisor" ("id")
    );

-- Stores URLs of redacted campaign documents.
CREATE TABLE
    "RedactedCampaignDocuments" (
        -- URL of the redacted document.
        "documentUrl" TEXT PRIMARY KEY,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Stores URLs of original campaign documents.
CREATE TABLE
    "CampaignDocuments" (
        -- URL of the document.
        "documentUrl" TEXT PRIMARY KEY,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Records a campaign's donation transactions.
CREATE TABLE
    "CampaignDonation" (
        -- Unique identifier for each donation.
        "id" UUID PRIMARY KEY,
        -- Total amount of the donation.
        "grossAmount" BIGINT NOT NULL,
        -- Fee charged for the donation service.
        "serviceFee" BIGINT NOT NULL,
        -- Timestamp of the donation transaction with time zone.
        "timestamp" TIMESTAMPTZ NOT NULL,
        -- Transaction reference number returned from the pqyment provider.
        "transactionRef" VARCHAR(255) NOT NULL UNIQUE,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Stores requests to extend the end date of a campaign.
CREATE TABLE
    "EndDateExtensionRequest" (
        -- Unique identifier for each extension request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        -- Justification for the extension request.
        "justification" TEXT NOT NULL,
        -- Indicates whether the request has been resolved.
        "isResolved" BOOLEAN NOT NULL DEFAULT FALSE,
        -- The new proposed end date with time zone.
        "newEndDate" TIMESTAMPTZ NOT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Stores requests to adjust the fundraising goal of a campaign.
CREATE TABLE
    "GoalAdjustmentRequest" (
        -- Unique identifier for each goal adjustment request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        -- Justification for the goal adjustment.
        "justification" TEXT NOT NULL,
        -- Indicates whether the request has been resolved.
        "isResolved" BOOLEAN NOT NULL DEFAULT FALSE,
        -- The new proposed fundraising goal.
        "newGoal" BIGINT NOT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Stores requests to change the status of a campaign.
CREATE TABLE
    "StatusChangeRequest" (
        -- Unique identifier for each status change request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        -- Justification for the status change.
        "justification" TEXT NOT NULL,
        -- Indicates whether the request has been resolved.
        "isResolved" BOOLEAN NOT NULL DEFAULT FALSE,
        -- The new proposed status.
        "newStatus" "CampaignStatus" NOT NULL,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Stores posts related to a campaign.
CREATE TABLE
    "CampaignPost" (
        -- Unique identifier for each campaign post.
        "id" UUID PRIMARY KEY,
        -- Title of the post.
        "title" VARCHAR(100) NOT NULL,
        -- Content of the post.
        "content" TEXT NOT NULL,
        -- Timestamp when the post became AVAILABLE TO THE PUBLIC. If this attribute not null, then the post is not available to the public. 
        "publicPostDate" TIMESTAMPTZ,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id")
    );

-- Stores requests to update a campaign post.
CREATE TABLE
    "PostUpdateRequest" (
        -- Unique identifier for each post update request.
        "id" UUID PRIMARY KEY,
        -- Title of the request.
        "title" VARCHAR(100) NOT NULL,
        -- Timestamp when the request was made with time zone.
        "requestDate" TIMESTAMPTZ NOT NULL DEFAULT NOW (),
        -- Justification for the post update.
        "justification" TEXT NOT NULL,
        -- Indicates whether the request has been resolved.
        "isResolved" BOOLEAN NOT NULL DEFAULT FALSE,
        -- Foreign key referencing the Campaign table.
        "campaignId" UUID NOT NULL REFERENCES "Campaign" ("id"),
        -- Foreign key referencing the CampaignPost table.
        "newPostId" UUID NOT NULL UNIQUE REFERENCES "CampaignPost" ("id")
    );
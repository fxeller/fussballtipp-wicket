package de.delmak.fussballtipp.persistence;

import java.util.List;

public class BracketStanding extends HibernateObject
{

	private Integer rank;

	public Integer getRank()
	{
		return rank;
	}

	public void setRank(Integer rank)
	{
		this.rank = rank;
	}

	private Integer bracketId;

	public Integer getBracketId()
	{
		return bracketId;
	}

	public void setBracketId(Integer bracketId)
	{
		this.bracketId = bracketId;
	}

	private String bracketDescription;

	public String getBracketDescription()
	{
		return bracketDescription;
	}

	public void setBracketDescription(String bracketDescription)
	{
		this.bracketDescription = bracketDescription;
	}

	private Integer teamId;

	public Integer getTeamId()
	{
		return teamId;
	}

	public void setTeamId(Integer teamId)
	{
		this.teamId = teamId;
	}

	private String teamDescription;

	public String getTeamDescription()
	{
		return teamDescription;
	}

	public void setTeamDescription(String teamDescription)
	{
		this.teamDescription = teamDescription;
	}

	private Integer matchesplayed;

	public Integer getMatchesplayed()
	{
		return matchesplayed;
	}

	public void setMatchesplayed(Integer matchesplayed)
	{
		this.matchesplayed = matchesplayed;
	}

	private Integer scorediff;

	public Integer getScorediff()
	{
		return scorediff;
	}

	public void setScorediff(Integer scorediff)
	{
		this.scorediff = scorediff;
	}

	private Integer goalsshot;

	public Integer getGoalsshot()
	{
		return goalsshot;
	}

	public void setGoalsshot(Integer goalsshot)
	{
		this.goalsshot = goalsshot;
	}

	private Integer goalstaken;

	public Integer getGoalstaken()
	{
		return goalstaken;
	}

	public void setGoalstaken(Integer goalstaken)
	{
		this.goalstaken = goalstaken;
	}

	private Integer points;

	public Integer getPoints()
	{
		return points;
	}

	public void setPoints(Integer points)
	{
		this.points = points;
	}

	private Integer wins;

	public Integer getWins()
	{
		return wins;
	}

	public void setWins(Integer wins)
	{
		this.wins = wins;
	}

	private Integer draws;

	public Integer getDraws()
	{
		return draws;
	}

	public void setDraws(Integer draws)
	{
		this.draws = draws;
	}

	private Integer losses;

	public Integer getLosses()
	{
		return losses;
	}

	public void setLosses(Integer losses)
	{
		this.losses = losses;
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s_%s", getClass().getName(), getBracketId(), getTeamDescription());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}

	public static List getListByBracketId(Integer bracketId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBracketStandingsByBracketId")
					.setInteger("bracketId", bracketId)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
}
